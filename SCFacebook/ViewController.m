//
//  ViewController.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SCFacebook.h"
#import "FriendsViewControler.h"

#import <QuartzCore/QuartzCore.h>

#define RemoveNull(field) ([[result objectForKey:field] isKindOfClass:[NSNull class]]) ? @"" : [result objectForKey:field];

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"SCFacebook";
    photoImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    photoImageView.layer.borderWidth = 2;
    
}

- (void)viewDidUnload
{
    [photoImageView release];
    photoImageView = nil;
    [nameLabel release];
    nameLabel = nil;
    [emailLabel release];
    emailLabel = nil;
    [birthdayLabel release];
    birthdayLabel = nil;
    [aboutTextView release];
    aboutTextView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [photoImageView release];
    [nameLabel release];
    [emailLabel release];
    [birthdayLabel release];
    [aboutTextView release];
    [super dealloc];
}

#pragma mark - Methods
-(void)getUserInfo{
    loadingView.hidden = NO;
    
    [SCFacebook getUserFQL:FQL_USER_STANDARD callBack:^(BOOL success, id result) {
        if (success) {
            NSLog(@"%@", result);
            
            loadingView.hidden = YES;
            
            nameLabel.text = RemoveNull(@"name");
            emailLabel.text = RemoveNull(@"email");
            birthdayLabel.text = RemoveNull(@"birthday_date");
            aboutTextView.text = RemoveNull(@"about_me");
            
            photoImageView.imageURL = [NSURL URLWithString:[result objectForKey:@"pic"]];
        }else{
            
            loadingView.hidden = YES;
            
            Alert(@"Alert", result);
        }
    }];
}


#pragma mark - Button Action
- (IBAction)login:(id)sender {
    
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            [self getUserInfo];
            Alert(@"Alert", result);
        }
    }];
}

- (IBAction)logout:(id)sender {
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        if (success) {
            nameLabel.text = @"Name";
            emailLabel.text = @"Email";
            birthdayLabel.text = @"Birthday";
            aboutTextView.text = @"About me"; 
            photoImageView.image = [UIImage imageNamed:@"nophoto.jpg"];
            Alert(@"Alert", result);
        } 
    }];
}

- (IBAction)getUserInfo:(id)sender {
    [self getUserInfo];
}

- (IBAction)getFriends:(id)sender {
    
    loadingView.hidden = NO;
    
    [SCFacebook getUserFriendsCallBack:^(BOOL success, id result) {
        if (success) {
            loadingView.hidden = YES;
            
            FriendsViewControler *friendsViewController = [[[FriendsViewControler alloc] init]autorelease];
            friendsViewController.friendsArray = result;
            [self.navigationController pushViewController:friendsViewController animated:YES];            
        }else{
            
            loadingView.hidden = YES;
            
            Alert(@"Alert", result);
        }
    }];
}

- (IBAction)publishYourWall:(id)sender {
    
    [SCFacebook userPostWallActionName:@"Portifolio" actionLink:@"http://www.lucascorrea.com/portifolio" paramName:@"I'm using the SCFacebook" paramCaption:@"SCFacebook" paramDescription:@"A simple and clean to implement login to facebook-ios-sdk using Blocks." paramLink:@"https://github.com/lucascorrea/SCFacebook" paramPicture: @"http://www.lucascorrea.com/lucas_apple.png" callBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", result);
        }else{
            Alert(@"Alert", result);            
        }
    }];
}

@end
