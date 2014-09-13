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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Init SCFacebook
    [SCFacebook initWithPermissions:@[@"user_about_me",
                                      @"user_birthday",
                                      @"email",
                                      @"user_photos",
                                      @"publish_stream",
                                      @"user_events",
                                      @"friends_events",
                                      @"manage_pages",
                                      @"share_item",
                                      @"publish_actions",
                                      @"user_friends",
                                      @"manage_pages",
                                      @"user_videos",
                                      @"public_profile"]];
    
    return YES;
}




#pragma mark - 
#pragma mark - SCFacebook Handle

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url
                             sourceApplication:sourceApplication];
    return wasHandled;
}


@end
