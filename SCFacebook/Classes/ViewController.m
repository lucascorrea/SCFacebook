//
//  ViewController.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
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
    return NO;
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

- (void)getUserInfo
{
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

- (IBAction)login:(id)sender 
{    
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            [self getUserInfo];
            Alert(@"Alert", result);
        }
    }];
}

- (IBAction)logout:(id)sender 
{    
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

- (IBAction)getUserInfo:(id)sender 
{
    [self getUserInfo];
}

- (IBAction)getFriends:(id)sender 
{    
    loadingView.hidden = NO;
    
    [SCFacebook getUserFriendsCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            
            FriendsViewControler *friendsViewController = [[[FriendsViewControler alloc] init]autorelease];
            friendsViewController.friendsArray = result;
            [self.navigationController pushViewController:friendsViewController animated:YES];            
        }else{
            Alert(@"Alert", result);
        }
    }];
}

- (IBAction)publishYourWall:(id)sender 
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"Option Publish"
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:@"Cancel"
                            otherButtonTitles:@"Link", @"Message", @"Message Dialog", @"Photo", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[sheet showFromRect:self.view.bounds inView:self.view animated:YES];
	[sheet release];
}




#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == actionSheet.destructiveButtonIndex) { return; }
    
    switch (buttonIndex) {
            
            //Link
		case 1:{
            loadingView.hidden = NO;
            [SCFacebook feedPostWithLinkPath:@"http://www.lucascorrea.com" caption:@"Portfolio" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
                Alert(@"Alert", result);            
            }];
            break;
		}
            
            //Message
		case 2:{
            loadingView.hidden = NO;
            [SCFacebook feedPostWithMessage:@"This is message" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
                Alert(@"Alert", result);            
            }];
            break;
		}
            //Message Dialog
		case 3:{
            
            [SCFacebook feedPostWithMessageDialogCallBack:^(BOOL success, id result) {
                Alert(@"Alert", result);            
            }];
            break;
		}
            //Photo
        case 4:{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
            loadingView.hidden = NO;
            [SCFacebook feedPostWithPhoto:image caption:@"This is message with photo" callBack:^(BOOL success, id result) {
                loadingView.hidden = YES;
                Alert(@"Alert", result);            
            }];
            break;
		}
	}
}

@end
