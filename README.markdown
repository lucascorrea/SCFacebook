The SCFacebook is a simpler and cleaner to use the api [Facebook-ios-sdk] (https://github.com/facebook/facebook-ios-sdk) with Blocks.

[![]( http://www.lucascorrea.com/scfacebook.png)] ![](http://www.lucascorrea.com/scfacebook_friends.png)

Installation
=================
Before you begin development with the Facebook iOS SDK, you will need to install the dev tools iOS, Git (the source control client we use for this SDK) and then clone the lastest version of the SDK from [Facebook-ios-sdk] ( https://github.com/facebook/facebook-ios-sdk).


Getting Started
=================

Now we need to copy the `SCFacebook.h` `SCFacebook.m` for your project.

In the class `SCFacebook.h` need to add your `kAppId` Facebook as example:
 
	#import "Facebook.h"
	#define kAppId @"YOUR_APP_ID"
	
	@interface SCFacebook : NSObject <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{

Once you have set up the `URL Scheme` as image below:

[![]( Https://developers.facebook.com/attachment/ios_config.png)]

Now in it's `AppDelegate` need to add two methods

	#import "SCFacebook.h"
	@implementation AppDelegate

	//SCFacebook Implementation
	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    	[[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    	return YES;
	}

	- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    	[[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    	return YES;
	}
	
Methods
===========

There is 10 methods:

	+(void)loginCallBack:(SCFacebookCallback)callBack;
	
	+(void)logoutCallBack:(SCFacebookCallback)callBack;
	
	+(void)getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack;
	
	+(void)getUserFriendsCallBack:(SCFacebookCallback)callBack;
	
	+(void)feedPostWithLinkPath:(NSString*)_url caption:(NSString*)_caption callBack:(SCFacebookCallback)callBack;
	
	+(void)feedPostWithMessage:(NSString*)_message callBack:(SCFacebookCallback)callBack;
	
	+(void)feedPostWithMessageDialogCallBack:(SCFacebookCallback)callBack;
	
	+(void)feedPostWithPhoto:(UIImage*)_photo caption:(NSString*)_caption callBack:(SCFacebookCallback)callBack;
	
	+(void)myFeedCallBack:(SCFacebookCallback)callBack;
	
	+(void)inviteFriendsWithMessage:(NSString *)_message callBack:(SCFacebookCallback)callBack;


Example Usage
=============

To use the component is very easy. Import the header for your class.

	#import "SCFacebook.h"
	@implementation ViewController

	#pragma mark - Button Action
	- (IBAction)login:(id)sender {
	    
		[SCFacebook loginCallBack:^(BOOL success, id result) {
	        	if (success) {
	        	}
	    	}];
	}

	- (IBAction)publishYourWallLink:(id)sender {
		[SCFacebook feedPostWithLinkPath:@"http://www.lucascorrea.com" caption:@"Portfolio" callBack:^(BOOL success, id result) {
           		if (success) {
	        	}
		}];
	}

	- (IBAction)publishYourWallMessage:(id)sender {
		[SCFacebook feedPostWithMessage:@"This is message" callBack:^(BOOL success, id result) {
	   		if (success) {
	        	}
		}];
	}

	//Getting Users name
	[SCFacebook getUserFQL:@"name" callBack:^(BOOL success, id result)
     	{
         	if(success)
         	{
             		NSMutableString *userName=[NSMutableString stringWithString:[NSString stringWithFormat:@"%@",[result objectForKey:@"name"]]];
         }	
     }];   

License
=============

SCFacebook is licensed under the MIT License:

Copyright (c) 2011 Lucas Correa (http://www.lucascorrea.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
