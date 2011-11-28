//
//  SCFacebook.h
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
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
