The SCFacebook is a simpler and cleaner to use the api [Facebook-ios-sdk] (https://github.com/facebook/facebook-ios-sdk) with Blocks.


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

There is 05 methods:

	+(void)loginCallBack:(SCFacebookCallback)callBack;
	
	+(void)logoutCallBack:(SCFacebookCallback)callBack;
	
	+(void)getUserFQL:(NSString*)fql callBack:(SCFacebookCallback)callBack;
	
	+(void)getUserFriendsCallBack:(SCFacebookCallback)callBack;
	
	+(void)userPostWallActionName:(NSString*)actName actionLink:(NSString*)actLink paramName:(NSString*)pName paramCaption:(NSString*)pCaption paramDescription:(NSString*)pDescription paramLink:(NSString*)pLink paramPicture:(NSString*)pPicture callBack:(SCFacebookCallback)callBack;


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
