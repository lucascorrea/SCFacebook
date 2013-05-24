//
//  SCFacebook.h
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2012 Siriuscode Solutions. All rights reserved.
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

#define OPEN_URL @"OPEN_URL"
#define FQL_USER_STANDARD @"uid, name, email, birthday_date, about_me, pic"
#define PERMISSIONS @"user_about_me",@"user_birthday",@"email", @"user_photos", @"publish_stream"


#define Alert(title,msg)  [[[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];

typedef void(^SCFacebookCallback)(BOOL success, id result);

typedef enum {
    FBPostTypeStatus = 0,
    FBPostTypePhoto = 1,
    FBPostTypeLink = 2
} FBPostType;

@interface SCFacebook : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{
    Facebook *_facebook;
    NSArray *_permissions;
    NSMutableDictionary *_userPermissions;
    SCFacebookCallback _callback;
    FBPostType postType;
}

@property (nonatomic, assign) FBPostType postType;

+ (void)initWithAppId:(NSString *)appId;
+ (BOOL)isSessionValid;
+ (void)loginCallBack:(SCFacebookCallback)callBack;
+ (void)logoutCallBack:(SCFacebookCallback)callBack;
+ (void)getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack;
+ (void)getUserFriendsCallBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithLinkPath:(NSString*)_url caption:(NSString*)_caption callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithMessage:(NSString*)_message callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithMessageDialogCallBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithPhoto:(UIImage*)_photo caption:(NSString*)_caption callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithPhoto:(UIImage*)_photo linkPath:(NSString*)_url caption:(NSString*)_caption callBack:(SCFacebookCallback)callBack;
+ (void)myFeedCallBack:(SCFacebookCallback)callBack;
+ (void)inviteFriendsWithMessage:(NSString *)_message callBack:(SCFacebookCallback)callBack;

@end
