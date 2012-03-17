//
//  FriendCell.m
//  SCFacebook
//
//  Created by Lucas Correa on 25/11/11.
//  Copyright (c) 2011 SiriusCode Solutions. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

@synthesize nameLabel, photoImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [photoImageView release];
    [nameLabel release];
    [super dealloc];
}
@end
