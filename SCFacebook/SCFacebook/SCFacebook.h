//
//  SCFacebook.h
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2014 Siriuscode Solutions. All rights reserved.
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
#import "FacebookSDK.h"

#define OPEN_URL @"OPEN_URL"

#define Alert(title,msg)  [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

typedef void(^SCFacebookCallback)(BOOL success, id result);

typedef NS_ENUM(NSInteger, FBPostType) {
    FBPostTypeStatus = 0,
    FBPostTypePhoto = 1,
    FBPostTypeLink = 2
};

typedef NS_ENUM(NSInteger, FBAlbumPrivacyType) {
    FBAlbumPrivacyEveryone = 0,
    FBAlbumPrivacyAllFriends = 1,
    FBAlbumPrivacyFriendsOfFriends = 2,
    FBAlbumPrivacySelf = 3
};

@interface SCFacebook : NSObject

/**

FacebookSDK version
 
Version 1.0, which is what we call the API as it existed the day before v2.0 was launched. We'll support v1.0 for one year and it will expire on April 30th, 2015.
Version 2.0, which is what this upgrade guide covers. Version 2.0 is supported for at least two years. At the earliest, it will expire on April 30th, 2016.
*/


@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) NSArray *permissions;
@property (assign, nonatomic) FBPostType postType;

+ (void)initWithPermissions:(NSArray *)permissions;
+ (BOOL)isSessionValid;
+ (void)loginCallBack:(SCFacebookCallback)callBack;
+ (void)logoutCallBack:(SCFacebookCallback)callBack;
+ (void)getUserFields:(NSString *)fields callBack:(SCFacebookCallback)callBack;

/**
 This will only return any friends who have used (via Facebook Login) the app making the request.
 If a friend of the person declines the user_friends permission, that friend will not show up in the friend list for this person.
 
 https://developers.facebook.com/docs/graph-api/reference/v2.1/user/friends/
 
 Permissions required: user_friends

 *  @param callBack 
 */
+ (void)getUserFriendsCallBack:(SCFacebookCallback)callBack;

+ (void)feedPostWithLinkPath:(NSString *)url caption:(NSString *)caption callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithMessage:(NSString *)message callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithPhoto:(UIImage *)photo caption:(NSString *)caption callBack:(SCFacebookCallback)callBack;
+ (void)feedPostWithVideo:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack;

+ (void)myFeedCallBack:(SCFacebookCallback)callBack;
+ (void)inviteFriendsWithMessage:(NSString *)message callBack:(SCFacebookCallback)callBack;
+ (void)userAccountsCallBack:(SCFacebookCallback)callBack;


+ (void)getPagesCallBack:(SCFacebookCallback)callBack;
+ (void)getPageById:(NSString *)pageId callBack:(SCFacebookCallback)callBack;
+ (void)feedPostForPage:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack;
+ (void)feedPostForPage:(NSString *)page message:(NSString *)message photo:(UIImage *)photo callBack:(SCFacebookCallback)callBack;
+ (void)feedPostForPage:(NSString *)page message:(NSString *)message link:(NSString *)url callBack:(SCFacebookCallback)callBack;
+ (void)feedPostForPage:(NSString *)page message:(NSString *)message photo:(UIImage *)photo link:(NSString *)url callBack:(SCFacebookCallback)callBack;
+ (void)feedPostAdminForPageName:(NSString *)page message:(NSString *)message callBack:(SCFacebookCallback)callBack;
+ (void)feedPostAdminForPageName:(NSString *)page video:(NSData *)videoData title:(NSString *)title description:(NSString *)description callBack:(SCFacebookCallback)callBack;


+ (void)getAlbumsCallBack:(SCFacebookCallback)callBack;
+ (void)getAlbumById:(NSString *)albumId callBack:(SCFacebookCallback)callBack;
+ (void)createAlbumName:(NSString *)name message:(NSString *)message privacy:(FBAlbumPrivacyType)privacy callBack:(SCFacebookCallback)callBack;
+ (void)feedPostPhotoForAlbumId:(NSString *)albumId callBack:(SCFacebookCallback)callBack;



+ (void)sendForPostOpenGraphObject:(NSMutableDictionary<FBOpenGraphObject> *)openGraphObject callBack:(SCFacebookCallback)callBack;
+ (void)sendForPostOpenGraphObject:(NSMutableDictionary<FBOpenGraphObject> *)openGraphObject withImage:(UIImage *)image callBack:(SCFacebookCallback)callBack;



+ (void)graphFacebookForMethodGET:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack;
+ (void)graphFacebookForMethodPOST:(NSString *)method params:(id)params callBack:(SCFacebookCallback)callBack;

@end
