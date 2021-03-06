//
//  AppDelegate.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeController.h"
#import "SCFacebook.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /**
     Init SCFacebook
     Add the necessary permissions
     
     If your app asks for more than than public_profile and email, it will require review by Facebook before your app can be used by people other than the app's developers.
     
     The time to review your app is usually about 7 business days. Some extra-sensitive permissions, as noted below, can take up to 14 business days.
     
     https://developers.facebook.com/docs/facebook-login/permissions/review
     **/
    [SCFacebook initWithReadPermissions:@[
                                          @"user_about_me",
                                          @"user_birthday",
                                          @"email",
                                          @"user_photos",
                                          @"user_events",
                                          @"user_friends",
                                          @"user_videos",
                                          @"public_profile"]
                     publishPermissions:@[
                                          @"manage_pages",
                                          @"publish_actions",
                                          @"publish_pages"
                                          ]
     ];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
    
}




#pragma mark -
#pragma mark - SCFacebook Handle

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    // Do the following if you use Mobile App Engagement Ads to get the deferred
    // app link after your app is installed.
    [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"Received error while fetching deferred app link %@", error);
        }
        if (url) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

@end
