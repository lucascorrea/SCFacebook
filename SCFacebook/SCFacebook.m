//
//  SCFacebook.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
//

#import "SCFacebook.h"
#import "SBJSON.h"


static SCFacebook * _scFacebook = nil;

@interface SCFacebook()
@property (nonatomic, retain) SCFacebookCallback callback;
@end



@implementation SCFacebook

@synthesize callback = _callback;



#pragma mark -
#pragma mark Singleton

+(SCFacebook *)shared {    
    @synchronized (self){
        
        static dispatch_once_t pred;
        
        dispatch_once(&pred, ^{
            _scFacebook = [[SCFacebook alloc] init];
        });
    }
    
    return _scFacebook;
}



#pragma mark -
#pragma mark Private Methods

- (BOOL)handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url];
}


- (void)loggedOut:(BOOL)clearInfo {
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (clearInfo && [defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
        
        // Nil out the session variables to prevent
        // the app from thinking there is a valid session
        if (nil != [_facebook accessToken]) {
            _facebook.accessToken = nil;
        }
        if (nil != [_facebook expirationDate]) {
            _facebook.expirationDate = nil;
        }
    }    
}

- (SCFacebook *) init
{
	self = [super init];
	if (self != nil){
        
        // Initialize Facebook
        _facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
        
        // Initialize user permissions
        _userPermissions = [[NSMutableDictionary alloc] initWithCapacity:1];
        
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        if (![_facebook isSessionValid]) {
            [self loggedOut:NO];
        } 
        
        //Notification
        [[NSNotificationCenter defaultCenter] addObserverForName:OPEN_URL object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSURL *url = (NSURL*)[note object];
            [self handleOpenURL:url];
        }];
    }
	return self;
}


-(void)_loginWithAppId:(NSString *)appId callBack:(SCFacebookCallback)callBack{
    
    if (!appId || [appId length] == 0) {
        NSString *error = @"Missing app ID. You cannot run the app until you provide this in the code.";
        
        Alert(@"ERROR", error)
        callBack(NO,error);
        [callBack release];
        return;
    }else{
        
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",appId];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] && 
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] && 
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            NSString *error = @"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist.";
            
            Alert(@"ERROR", error)
            callBack(NO,error);
            [callBack release];
            return;
        }
        
        // Check and retrieve authorization information
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        if (![_facebook isSessionValid]) {
            _facebook.sessionDelegate = self;
            
            //Permissions
            // http://developers.facebook.com/docs/reference/api/permissions/
            
            _permissions  = [NSArray arrayWithObjects:PERMISSIONS, nil];
            [_facebook authorize:_permissions];
            
            self.callback = [[callBack copy] autorelease];
        } 
        else {
            callBack(YES,@"Logged");
            [callBack release];
        }
    }
}

-(void)_logoutCallBack:(SCFacebookCallback)callBack{
    self.callback = [[callBack copy] autorelease];
    [_facebook logout:self];
}


-(void)_getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack{
    
    if (![_facebook isSessionValid]) {
        callBack(NO, @"Not logged in");
        [callBack release];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"SELECT %@ FROM user WHERE uid=me()",fql], @"query",
                                   nil];
    [_facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"POST" andDelegate:self];
    self.callback = [[callBack copy] autorelease];  
}

-(void)_getUserFriendsCallBack:(SCFacebookCallback)callBack{
    if (![_facebook isSessionValid]) {
        callBack(NO, @"Not logged in");
        [callBack release];
        return;
    }
    
    [_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    self.callback = [[callBack copy] autorelease];
}

-(void)_userPostWallActionName:(NSString*)actName actionLink:(NSString*)actLink paramName:(NSString*)pName paramCaption:(NSString*)pCaption paramDescription:(NSString*)pDescription paramLink:(NSString*)pLink paramPicture:(NSString*)pPicture callBack:(SCFacebookCallback)callBack{
    
    if (![_facebook isSessionValid]) {
        callBack(NO, @"Not logged in");
        [callBack release];
        return;
    }
    
    NSString *actionLinksStr = nil;
    
    if (![actName isKindOfClass:[NSNull class]] && ![actLink isKindOfClass:[NSNull class]]) {
        SBJSON *jsonWriter = [[SBJSON new] autorelease];
        
        // The action links to be shown with the post in the feed
        
        NSMutableDictionary *actionLinks = [[NSMutableDictionary alloc] init];
        if (![actName isKindOfClass:[NSNull class]]) {
            [actionLinks setValue:actName forKey:@"name"];
        }
        
        if (![actLink isKindOfClass:[NSNull class]]) {
            [actionLinks setValue:actLink forKey:@"link"];
        }
        
        actionLinksStr = [jsonWriter stringWithObject:actionLinks];  
        [actionLinks release];
    }
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    if (![pName isKindOfClass:[NSNull class]]) {
        [params setValue:pName forKey:@"name"];   
    }
    
    if (![pCaption isKindOfClass:[NSNull class]]) {
        [params setValue:pCaption forKey:@"caption"];   
    }
    
    if (![pDescription isKindOfClass:[NSNull class]]) {
        [params setValue:pDescription forKey:@"description"];   
    }
    
    if (![pLink isKindOfClass:[NSNull class]]) {
        [params setValue:pLink forKey:@"link"];   
    }
    
    if (![pPicture isKindOfClass:[NSNull class]]) {
        [params setValue:pPicture forKey:@"picture"];   
    }
    
    if (![pName isKindOfClass:[NSNull class]]) {
        [params setValue:pName forKey:@"name"];   
    }
    
    if (actionLinksStr != nil) {
        [params setValue:actionLinksStr forKey:@"actions"];   
    }
    
    if ([params count] > 0) {
        [_facebook dialog:@"feed" andParams:params andDelegate:self];
        self.callback = [[callBack copy] autorelease];        
    }else{
        callBack(NO, @"ERROR");
    }
}




#pragma mark - 
#pragma mark Public Methods Class

+(void)loginCallBack:(SCFacebookCallback)callBack{
	[[SCFacebook shared] _loginWithAppId:kAppId callBack:callBack];
}

+(void)logoutCallBack:(SCFacebookCallback)callBack{
	[[SCFacebook shared] _logoutCallBack:callBack];
}

+(void)getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack{
	[[SCFacebook shared] _getUserFQL:fql callBack:callBack];
}


+(void)getUserFriendsCallBack:(SCFacebookCallback)callBack{
	[[SCFacebook shared] _getUserFriendsCallBack:callBack];
}


+(void)userPostWallActionName:(NSString*)actName actionLink:(NSString*)actLink paramName:(NSString*)pName paramCaption:(NSString*)pCaption paramDescription:(NSString*)pDescription paramLink:(NSString*)pLink paramPicture:(NSString*)pPicture callBack:(SCFacebookCallback)callBack{
    [[SCFacebook shared] _userPostWallActionName:actName actionLink:actLink paramName:pName paramCaption:pCaption paramDescription:pDescription paramLink:pLink paramPicture:pPicture callBack:callBack];
}






#pragma mark - 
#pragma mark FBSessionDelegate Methods

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    self.callback(YES,@"Success");
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    self.callback(NO,@"Not Login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    [self loggedOut:YES];
    self.callback(YES,@"Logout successfully");
}





#pragma mark -
#pragma mark FBRequestDelegate Methods

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        if ([result count] > 0) {
            result = [result objectAtIndex:0];            
            self.callback(YES,result);
        }else{
            self.callback(NO,result);
        }
    } else {
        NSArray *resultData = [result objectForKey:@"data"];
        if ([resultData count] > 0) {
            self.callback(YES,resultData);
        }else{
            self.callback(NO,result);
        }
        //        _userPermissions = [[result objectForKey:@"data"] objectAtIndex:0];
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
    
    self.callback(YES,[[error userInfo] objectForKey:@"error_msg"]);
    
    // Show logged out state if:
    // 1. the app is no longer authorized
    // 2. the user logged out of Facebook from m.facebook.com or the Facebook app
    // 3. the user has changed their password
    if ([error code] == 190) {
        [self loggedOut:YES];
    }
}



#pragma mark - 
#pragma mark FBDialogDelegate Methods

/**
 * Called when a UIServer Dialog successfully return. Using this callback
 * instead of dialogDidComplete: to properly handle successful shares/sends
 * that return ID data back.
 */
- (void)dialogDidComplete:(FBDialog *)dialog{
    self.callback(YES, @"Publish Successfully");
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
    self.callback(NO, @"Dialog dismissed.");
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    self.callback(NO, [[error userInfo] objectForKey:@"error_msg"]);
}

@end
