//
//  SCFacebook.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011-present Siriuscode Solutions. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SCFacebook.h"

@interface SCFacebook() <FBSDKAppInviteDialogDelegate, FBSDKSharingDelegate>

@property (strong, nonatomic) FBSDKLoginManager *loginManager;
@property (strong, nonatomic) SCFacebookCallback inviteCallcack;
@property (strong, nonatomic) SCFacebookCallback sharedCallcack;

@end

@implementation SCFacebook


#pragma mark -
#pragma mark - Private Methods

- (void)initWithReadPermissions:(NSArray *)readPermissions publishPermissions:(NSArray *)publishPermissions;
{
    self.readPermissions = readPermissions;
    self.publishPermissions = publishPermissions;
}

- (BOOL)isSessionValid
{
    return [FBSDKAccessToken currentAccessToken] != nil;
}



- (void)loginCallBack:(SCFacebookCallback)callBack
{
    [self loginWithBehavior:FBSDKLoginBehaviorSystemAccount CallBack:callBack];
}

- (void)loginWithBehavior:(FBSDKLoginBehavior)behavior CallBack:(SCFacebookCallback)callBack
{
    if (behavior) {
        self.loginManager.loginBehavior = behavior;
    }
    
    [self.loginManager logInWithReadPermissions: self.readPermissions
                             fromViewController: nil
                                        handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                            if (error) {
                                                callBack(NO, error.localizedDescription);
                                            } else if (result.isCancelled) {
                                                callBack(NO, @"Cancelled");
                                            } else {
                                                if(callBack){
                                                    callBack(!error, result);
                                                }
                                            }
                                        }];
}


- (void)logoutCallBack:(SCFacebookCallback)callBack
{
    [self.loginManager logOut];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    
    callBack(YES, @"Logout successfully");
}

- (void)getUserFields:(NSString *)fields callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [self graphFacebookForMethodGET:@"me" params:@{@"fields" : fields} callBack:callBack];
}


- (void)getUserFriendsCallBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:(@"user_friends")]) {
        [self graphFacebookForMethodGET:@"me/friends" params:nil callBack:callBack];
    } else {
        
        self.loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        [self.loginManager logInWithPublishPermissions:self.readPermissions fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                callBack(NO, error.localizedDescription);
            } else if (result.isCancelled) {
                callBack(NO, @"Cancelled");
            } else {
                [self graphFacebookForMethodGET:@"me/friends" params:nil callBack:callBack];
            }
        }];
    }
}

- (void)feedPostWithLinkPath:(NSString *)url caption:(NSString *)caption message:(NSString *)message photo:(UIImage *)photo video:(NSData *)videoData callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //Need to provide POST parameters to the Facebook SDK for the specific post type
    NSString *graphPath = @"me/feed";
    
    switch (self.postType) {
        case FBPostTypeLink:{
            [params setObject:(url != nil) ? url : @"" forKey:@"link"];
            [params setObject:(caption != nil) ? caption : @"" forKey:@"description"];
            break;
        }
        case FBPostTypeStatus:{
            [params setObject:(message != nil) ? message : @"" forKey:@"message"];
            break;
        }
        case FBPostTypePhoto:{
            graphPath = @"me/photos";
            [params setObject:UIImagePNGRepresentation(photo) forKey:@"source"];
            [params setObject:(caption != nil) ? caption : @"" forKey:@"message"];
            break;
        }
        case FBPostTypeVideo:{
            graphPath = @"me/videos";
            
            if (videoData == nil) {
                callBack(NO, @"Not logged in");
                return;
            }
            
            [params setObject:videoData forKey:@"video.mp4"];
            [params setObject:caption forKey:@"title"];
            [params setObject:message forKey:@"description"];
            break;
        }
            
        default:
            break;
    }
    
    [self graphFacebookForMethodPOST:graphPath params:params callBack:callBack];
}

- (void)myFeedCallBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [self graphFacebookForMethodPOST:@"me/feed" params:nil callBack:callBack];
}

- (void)inviteFriendsWithAppLinkURL:(NSURL *)url previewImageURL:(NSURL *)preview callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = url;
    
    if (preview) {
        //optionally set previewImageURL
        content.appInvitePreviewImageURL = preview;
    }
    
    [FBSDKAppInviteDialog showFromViewController:nil withContent:content
                                 delegate:self];
    
    self.inviteCallcack = callBack;
}

- (void)getPagesCallBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:(@"manage_pages")]) {
        [self graphFacebookForMethodGET:@"me/accounts" params:nil callBack:callBack];
    } else {
        
        self.loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        [self.loginManager logInWithPublishPermissions:self.publishPermissions fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                callBack(NO, error.localizedDescription);
            } else if (result.isCancelled) {
                callBack(NO, @"Cancelled");
            } else {
                [self graphFacebookForMethodGET:@"me/accounts" params:nil callBack:callBack];
            }
        }];
    }
    
}

- (void)getPageById:(NSString *)pageId callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!pageId) {
        callBack(NO, @"Page id or name required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodGET:pageId params:nil callBack:callBack];
}

- (void)feedPostForPage:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!page) {
        callBack(NO, @"Page id or name required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodPOST:[NSString stringWithFormat:@"%@/feed", page] params:@{@"message": message} callBack:callBack];
}

- (void)feedPostForPage:(NSString *)page message:(NSString *)message photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!page) {
        callBack(NO, @"Page id or name required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodPOST:[NSString stringWithFormat:@"%@/photos", page] params:@{@"message": message, @"source" : UIImagePNGRepresentation(photo)} callBack:callBack];
}

- (void)feedPostForPage:(NSString *)page message:(NSString *)message link:(NSString *)url callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!page) {
        callBack(NO, @"Page id or name required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodPOST:[NSString stringWithFormat:@"%@/feed", page] params:@{@"message": message, @"link" : url} callBack:callBack];
}

- (void)feedPostForPage:(NSString *)page video:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!page) {
        callBack(NO, @"Page id or name required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodPOST:[NSString stringWithFormat:@"%@/videos", page]
                                    params:@{@"title" : title,
                                             @"description" : description,
                                             @"video.mp4" : videoData} callBack:callBack];
}

- (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack
{
    
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [SCFacebook getPagesCallBack:^(BOOL success, id result) {
        
        if (success) {
            
            NSDictionary *dicPageAdmin = nil;
            
            for (NSDictionary *dic in result[@"data"]) {
                
                if ([dic[@"name"] isEqualToString:page]) {
                    dicPageAdmin = dic;
                    break;
                }
            }
            
            if (!dicPageAdmin) {
                callBack(NO, @"Page not found!");
                return;
            }
            
            
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"%@/feed",dicPageAdmin[@"id"]] parameters:@{@"message" : message} HTTPMethod:@"POST"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    callBack(NO, [error domain]);
                }else{
                    callBack(YES, result);
                }
            }];
        }
    }];
}

- (void)feedPostAdminForPageName:(NSString *)page video:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack
{
    
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [SCFacebook getPagesCallBack:^(BOOL success, id result) {
        
        if (success) {
            
            NSDictionary *dicPageAdmin = nil;
            
            for (NSDictionary *dic in result[@"data"]) {
                
                if ([dic[@"name"] isEqualToString:page]) {
                    dicPageAdmin = dic;
                    break;
                }
            }
            
            if (!dicPageAdmin) {
                callBack(NO, @"Page not found!");
                return;
            }
            
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"%@/feed", dicPageAdmin[@"id"]]
                                          parameters:@{
                                                       @"title" : title,
                                                       @"description" : description,
                                                       @"video.mp4" : videoData,
                                                       @"access_token" : dicPageAdmin[@"access_token"]
                                                       }
                                          HTTPMethod:@"POST"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    callBack(NO, [error domain]);
                }else{
                    callBack(YES, result);
                }
            }];
        }
    }];
}

- (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message link:(NSString *)url callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [SCFacebook getPagesCallBack:^(BOOL success, id result) {
        
        if (success) {
            
            NSDictionary *dicPageAdmin = nil;
            
            for (NSDictionary *dic in result[@"data"]) {
                
                if ([dic[@"name"] isEqualToString:page]) {
                    dicPageAdmin = dic;
                    break;
                }
            }
            
            if (!dicPageAdmin) {
                callBack(NO, @"Page not found!");
                return;
            }
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"%@/feed", dicPageAdmin[@"id"]]
                                          parameters:@{
                                                       @"message" : message,
                                                       @"link" : url,
                                                       @"access_token" : dicPageAdmin[@"access_token"]
                                                       }
                                          HTTPMethod:@"POST"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    callBack(NO, [error domain]);
                }else{
                    callBack(YES, result);
                }
            }];
        }
    }];
}

- (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [SCFacebook getPagesCallBack:^(BOOL success, id result) {
        
        if (success) {
            
            NSDictionary *dicPageAdmin = nil;
            
            for (NSDictionary *dic in result[@"data"]) {
                
                if ([dic[@"name"] isEqualToString:page]) {
                    dicPageAdmin = dic;
                    break;
                }
            }
            
            if (!dicPageAdmin) {
                callBack(NO, @"Page not found!");
                return;
            }
            
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"%@/feed", dicPageAdmin[@"id"]]
                                          parameters:@{
                                                       @"message" : message,
                                                       @"source" : UIImagePNGRepresentation(photo),
                                                       @"access_token" : dicPageAdmin[@"access_token"]                                                       }
                                          HTTPMethod:@"POST"];
            
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    callBack(NO, [error domain]);
                }else{
                    callBack(YES, result);
                }
            }];
        }
    }];
}

- (void)getAlbumsCallBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    [self graphFacebookForMethodGET:@"me/albums" params:nil callBack:callBack];
}

- (void)getAlbumById:(NSString *)albumId callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!albumId) {
        callBack(NO, @"Album id required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodGET:albumId params:nil callBack:callBack];
}

- (void)getPhotosAlbumById:(NSString *)albumId callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!albumId) {
        callBack(NO, @"Album id required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodGET:[NSString stringWithFormat:@"%@/photos", albumId] params:nil callBack:callBack];
}

- (void)createAlbumName:(NSString *)name message:(NSString *)message privacy:(FBAlbumPrivacyType)privacy callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!name && !message) {
        callBack(NO, @"Name and message required");
        return;
    }
    
    NSString *privacyString = @"";
    
    switch (privacy) {
        case FBAlbumPrivacyEveryone:
            privacyString = @"EVERYONE";
            break;
        case FBAlbumPrivacyAllFriends:
            privacyString = @"ALL_FRIENDS";
            break;
        case FBAlbumPrivacyFriendsOfFriends:
            privacyString = @"FRIENDS_OF_FRIENDS";
            break;
        case FBAlbumPrivacySelf:
            privacyString = @"SELF";
            break;
        default:
            break;
    }
    
    [SCFacebook graphFacebookForMethodPOST:@"me/albums" params:@{@"name" : (name != nil) ? name : @"",
                                                                 @"message" : message,
                                                                 @"value" : privacyString} callBack:callBack];
}

- (void)feedPostForAlbumId:(NSString *)albumId photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    if (!albumId) {
        callBack(NO, @"Album id required");
        return;
    }
    
    [SCFacebook graphFacebookForMethodPOST:[NSString stringWithFormat:@"%@/photos", albumId] params:@{@"source": UIImagePNGRepresentation(photo)} callBack:callBack];
}

- (void)sendForPostOpenGraphWithActionType:(NSString *)actionType graphObject:(FBSDKShareOpenGraphObject *)openGraphObject objectName:(NSString *)objectName viewController:(UIViewController *)viewController callBack:(SCFacebookCallback)callBack
{
    if (![self isSessionValid]) {
        callBack(NO, @"Not logged in");
        return;
    }
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = actionType;
    [action setObject:openGraphObject forKey:objectName];
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.action = action;
    content.previewPropertyName = objectName;
    
    [FBSDKShareDialog showFromViewController:viewController
                                 withContent:content
                                    delegate:self];
    
    self.sharedCallcack = callBack;
}

- (void)graphFacebookForMethodPOST:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack
{
    [self graphFacebookForMethod:method httpMethod:@"POST" params:params callBack:callBack];
}

- (void)graphFacebookForMethodGET:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack
{
    [self graphFacebookForMethod:method httpMethod:@"GET" params:params callBack:callBack];
}

- (void)graphFacebookForMethod:(NSString *)method httpMethod:(NSString *)httpMethod params:(id)params callBack:(SCFacebookCallback)callBack
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:method
                                       parameters:params
                                       HTTPMethod:httpMethod]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if ([error.userInfo[FBSDKGraphRequestErrorGraphErrorCode] isEqual:@200]) {
             callBack(NO, error);
         } else {
             callBack(YES, result);
         }
     }];
}



#pragma mark -
#pragma mark - FBSDKAppInviteDialogDelegate methods

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    self.inviteCallcack(YES, results);
    self.inviteCallcack = nil;
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    self.inviteCallcack(NO, error);
    self.inviteCallcack = nil;
}



#pragma mark -
#pragma mark - FBSDKSharingDelegate methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    self.sharedCallcack(YES, results);
    self.sharedCallcack = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    self.sharedCallcack(NO, error);
    self.sharedCallcack = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    self.sharedCallcack(YES, @"Cancelled");
    self.sharedCallcack = nil;
}





#pragma mark -
#pragma mark - Singleton

+ (SCFacebook *)shared
{
    static SCFacebook *scFacebook = nil;
    
    @synchronized (self){
        
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            scFacebook = [[SCFacebook alloc] init];
            scFacebook.loginManager = [[FBSDKLoginManager alloc] init];
        });
    }
    
    return scFacebook;
}



#pragma mark -
#pragma mark - Public Methods

+ (void)initWithReadPermissions:(NSArray *)readPermissions publishPermissions:(NSArray *)publishPermissions
{
    [[SCFacebook shared] initWithReadPermissions:readPermissions publishPermissions:publishPermissions];
}

+(BOOL)isSessionValid
{
    return [[SCFacebook shared] isSessionValid];
}

+ (void)loginCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] loginCallBack:callBack];
}

+ (void)loginWithBehavior:(FBSDKLoginBehavior)behavior CallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] loginWithBehavior:behavior CallBack:callBack];
}

+ (void)logoutCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] logoutCallBack:callBack];
}

+ (void)getUserFields:(NSString *)fields callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getUserFields:fields callBack:callBack];
}

+ (void)getUserFriendsCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getUserFriendsCallBack:callBack];
}

+ (void)feedPostWithLinkPath:(NSString *)url caption:(NSString *)caption callBack:(SCFacebookCallback)callBack
{
    [SCFacebook shared].postType = FBPostTypeLink;
    [[SCFacebook shared] feedPostWithLinkPath:url caption:caption message:nil photo:nil video:nil callBack:callBack];
}

+ (void)feedPostWithMessage:(NSString *)message callBack:(SCFacebookCallback)callBack
{
    [SCFacebook shared].postType = FBPostTypeStatus;
    [[SCFacebook shared] feedPostWithLinkPath:nil caption:nil message:message photo:nil video:nil callBack:callBack];
}

+ (void)feedPostWithPhoto:(UIImage *)photo caption:(NSString *)caption callBack:(SCFacebookCallback)callBack
{
    [SCFacebook shared].postType = FBPostTypePhoto;
    [[SCFacebook shared] feedPostWithLinkPath:nil caption:caption message:nil photo:photo video:nil callBack:callBack];
}

+ (void)feedPostWithVideo:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack
{
    [SCFacebook shared].postType = FBPostTypeVideo;
    [[SCFacebook shared] feedPostWithLinkPath:nil caption:title message:description photo:nil video:videoData callBack:callBack];
}

+ (void)myFeedCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] myFeedCallBack:callBack];
}

+ (void)inviteFriendsWithAppLinkURL:(NSURL *)url previewImageURL:(NSURL *)preview callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] inviteFriendsWithAppLinkURL:url previewImageURL:preview callBack:callBack];
}

+ (void)getPagesCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getPagesCallBack:callBack];
}

+ (void)getPageById:(NSString *)pageId callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getPageById:pageId callBack:callBack];
}

+ (void)feedPostForPage:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostForPage:page message:message callBack:callBack];
}

+ (void)feedPostForPage:(NSString *)page message:(NSString *)message photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostForPage:page message:message photo:photo callBack:callBack];
}

+ (void)feedPostForPage:(NSString *)page message:(NSString *)message link:(NSString *)url callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostForPage:page message:message link:url callBack:callBack];
}

+ (void)feedPostForPage:(NSString *)page video:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostForPage:page video:videoData title:title description:description callBack:callBack];
}

+ (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostAdminForPageName:page message:message callBack:callBack];
}

+ (void)feedPostAdminForPageName:(NSString *)page video:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostAdminForPageName:page video:videoData title:title description:description callBack:callBack];
}

+ (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message link:(NSString *)url callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostAdminForPageName:page message:message link:url callBack:callBack];
}

+ (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostAdminForPageName:page message:message photo:photo callBack:callBack];
}

+ (void)getAlbumsCallBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getAlbumsCallBack:callBack];
}

+ (void)getAlbumById:(NSString *)albumId callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getAlbumById:albumId callBack:callBack];
}

+ (void)getPhotosAlbumById:(NSString *)albumId callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] getPhotosAlbumById:albumId callBack:callBack];
}

+ (void)createAlbumName:(NSString *)name message:(NSString *)message privacy:(FBAlbumPrivacyType)privacy callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] createAlbumName:name message:message privacy:privacy callBack:callBack];
}

+ (void)feedPostForAlbumId:(NSString *)albumId photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] feedPostForAlbumId:albumId photo:photo callBack:callBack];
}

+ (void)sendForPostOpenGraphWithActionType:(NSString *)actionType graphObject:(FBSDKShareOpenGraphObject *)openGraphObject objectName:(NSString *)objectName viewController:(UIViewController *)viewController callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] sendForPostOpenGraphWithActionType:actionType graphObject:openGraphObject objectName:objectName viewController:(UIViewController *)viewController callBack:callBack];
}

+ (void)graphFacebookForMethodGET:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] graphFacebookForMethodGET:method params:params callBack:callBack];
}

+ (void)graphFacebookForMethodPOST:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack
{
    [[SCFacebook shared] graphFacebookForMethodPOST:method params:params callBack:callBack];
}


@end
