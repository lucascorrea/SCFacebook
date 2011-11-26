//
//  ViewController.h
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ViewController : UIViewController{
    
    IBOutlet EGOImageView *photoImageView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UITextView *aboutTextView;
}

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)getUserInfo:(id)sender;
- (IBAction)getFriends:(id)sender;
- (IBAction)publishYourWall:(id)sender;

@end
