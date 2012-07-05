//
//  FriendsViewControler.h
//  SCFacebook
//
//  Created by Lucas Correa on 25/11/11.
//  Copyright (c) 2011 SiriusCode Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewControler : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *friendsArray;

@end
