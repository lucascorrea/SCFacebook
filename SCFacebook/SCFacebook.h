//
//  SCFacebook.h
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

#warning Your application App ID/API Key Facebook
#define kAppId @"140422319335414"

#define OPEN_URL @"OPEN_URL"
#define FQL_USER_STANDARD @"uid, name, email, birthday_date, about_me, pic"
#define PERMISSIONS @"user_about_me",@"user_birthday",@"email"


#define Alert(title,msg)  [[[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];

typedef void(^SCFacebookCallback)(BOOL success, id result);

@interface SCFacebook : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{
    Facebook *_facebook;
    NSArray *_permissions;
    NSMutableDictionary *_userPermissions;
    SCFacebookCallback _callback;
}

+(SCFacebook *)shared;
+(void)loginCallBack:(SCFacebookCallback)callBack;
+(void)logoutCallBack:(SCFacebookCallback)callBack;
+(void)getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack;
+(void)getUserFriendsCallBack:(SCFacebookCallback)callBack;
+(void)userPostWallActionName:(NSString*)actName actionLink:(NSString*)actLink paramName:(NSString*)pName paramCaption:(NSString*)pCaption paramDescription:(NSString*)pDescription paramLink:(NSString*)pLink paramPicture:(NSString*)pPicture callBack:(SCFacebookCallback)callBack;

@end
