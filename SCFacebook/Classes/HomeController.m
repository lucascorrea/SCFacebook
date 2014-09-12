//
//  HomeController.m
//  SCFacebook
//
//  Created by Lucas Correa on 23/11/11.
//  Copyright (c) 2011 Siriuscode Solutions. All rights reserved.
//

#import "HomeController.h"
#import "SCFacebook.h"
#import "FriendsViewControler.h"
#import "HomeCell.h"

#import <QuartzCore/QuartzCore.h>

#define RemoveNull(field) ([[result objectForKey:field] isKindOfClass:[NSNull class]]) ? @"" : [result objectForKey:field];

@interface HomeController ()

@property (strong, nonatomic) NSMutableArray *itemsArray;
@property (strong, nonatomic) UIActionSheet *userSheet;
@property (strong, nonatomic) UIActionSheet *openGraphSheet;
@property (strong, nonatomic) UIActionSheet *pageSheet;
@property (strong, nonatomic) UIActionSheet *albumSheet;

@end


@implementation HomeController

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
    
    [self.itemsArray addObject:@"Login"];
    [self.itemsArray addObject:@"Logout"];
    [self.itemsArray addObject:@"Get User info"];
    [self.itemsArray addObject:@"Get Friends"];
    [self.itemsArray addObject:@"Publish to your wall"];
    [self.itemsArray addObject:@"Invite Friends"];
    [self.itemsArray addObject:@"OpenGraph"];
    [self.itemsArray addObject:@"Pages"];
    [self.itemsArray addObject:@"Albums"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark -
#pragma mark - Property

- (NSMutableArray *)itemsArray
{
    if(!_itemsArray) _itemsArray = [[NSMutableArray alloc] init];
    return _itemsArray;
}


#pragma mark -
#pragma mark - UIStoryboardSegue Delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendSegue"]) {
        FriendsViewControler *friendsViewController = segue.destinationViewController;
        friendsViewController.friendsArray = sender;
    }
}



#pragma mark -
#pragma mark - Methods

- (void)getUserInfo
{
    loadingView.hidden = NO;
    
    [SCFacebook getUserFields:@"id, name, email, birthday, about, picture" callBack:^(BOOL success, id result) {
        if (success) {
            NSLog(@"%@", result);
            loadingView.hidden = YES;
        }else{
            loadingView.hidden = YES;
            Alert(@"Alert", [result description]);
        }
    }];
}

- (void)login
{
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            Alert(@"Alert", @"Success");
        }else{
            Alert(@"Alert", [result description]);
        }
    }];
}

- (void)logout
{
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", [result description]);
        }
    }];
}

- (void)getFriends
{
    loadingView.hidden = NO;
    
    [SCFacebook getUserFriendsCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            [self performSegueWithIdentifier:@"FriendSegue" sender:result];
        }else{
            Alert(@"Alert", [result description]);
        }
    }];
}

- (void)publishYourWall
{
    self.userSheet = [[UIActionSheet alloc]
                      initWithTitle:@"Option Publish"
                      delegate:self
                      cancelButtonTitle:nil
                      destructiveButtonTitle:@"Cancel"
                      otherButtonTitles:@"Message", @"Link", @"Photo", nil];
    self.userSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.userSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)publishPageWall
{
    self.pageSheet = [[UIActionSheet alloc]
                      initWithTitle:@"Option Pages"
                      delegate:self
                      cancelButtonTitle:nil
                      destructiveButtonTitle:@"Cancel"
                      otherButtonTitles:
                      @"Get Pages",
                      @"Message",
                      @"Message + Photo",
                      @"Message + Link",
                      @"Title + Description + Video",
                      @"Admin Message",
                      @"Admin Message + Link",
                      @"Admin Message + Photo",
                      @"Admin Title + Description + Video", nil];
    self.pageSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.pageSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)publishAlbums
{
    self.albumSheet = [[UIActionSheet alloc]
                      initWithTitle:@"Option Albums"
                      delegate:self
                      cancelButtonTitle:nil
                      destructiveButtonTitle:@"Cancel"
                      otherButtonTitles:
                      @"Get Albums",
                      @"Get AlbumId",
                      @"Get Photos the album",
                      @"Create Album",
                      @"Post Photo in album", nil];
    self.albumSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.albumSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)publishOpenGraph
{
    self.openGraphSheet = [[UIActionSheet alloc]
                           initWithTitle:@"Option Open Graph - Custom Stories"
                           delegate:self
                           cancelButtonTitle:nil
                           destructiveButtonTitle:@"Cancel"
                           otherButtonTitles:
                           @"Post open graph",
                           @"Post open graph with image upload",nil];
    self.openGraphSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.openGraphSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)openGraph
{
    loadingView.hidden = NO;
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject
                                                      openGraphObjectForPostWithType:@"fblucascorreatest:graphtest"
                                                      title:@"My first post with open graph"
                                                      image:@"https://fbstatic-a.akamaihd.net/images/devsite/attachment_blank.png"
                                                      url:@"http://www.lucascorrea.com"
                                                      description:@"Description"];
    
    [SCFacebook sendForPostOpenGraphPath:@"/me/fblucascorreatest:test" graphObject:object objectName:@"graphtest" callBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            Alert(@"Alert", [result description]);
        }else{
            Alert(@"Alert", [result description]);
        }
    }];
}

- (void)openGraphWithImage
{
    loadingView.hidden = NO;
    
    // instantiate a Facebook Open Graph object
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    // specify that this Open Graph object will be posted to Facebook
    object.provisionedForPost = YES;
    
    // for og:title
    object[@"title"] = @"My first post with open graph";
    
    // for og:type, this corresponds to the Namespace you've set for your app and the object type name
    object[@"type"] = @"fblucascorreatest:graphtest";
    
    // for og:description
    object[@"description"] = @"Description";
    
    // for og:url, we cover how this is used in the "Deep Linking" section below
    object[@"url"] = @"http://www.lucascorrea.com";
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
    
    [SCFacebook sendForPostOpenGraphPath:@"/me/fblucascorreatest:test" graphObject:object objectName:@"graphtest" withImage:image callBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            Alert(@"Alert", [result description]);
        }else{
            Alert(@"Alert", [result description]);
        }
    }];
}


- (void)inviteFriends
{
    [SCFacebook inviteFriendsWithMessage:@"Invite Friends" callBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", [result description]);
        }else{
            Alert(@"Alert", [result description]);
        }
    }];
}




#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) { return; }
    
    if (self.userSheet == actionSheet) {
        
        switch (buttonIndex) {
                
                //Message
            case 1:{
                loadingView.hidden = NO;
                [SCFacebook feedPostWithMessage:@"This is message" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Link
            case 2:{
                loadingView.hidden = NO;
                [SCFacebook feedPostWithLinkPath:@"http://www.lucascorrea.com" caption:@"Portfolio" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                
                break;
                //Photo
            case 3:{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
                loadingView.hidden = NO;
                [SCFacebook feedPostWithPhoto:image caption:@"This is message with photo" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
            default:
                break;
        }
    }
    
    //Pages and Page Admin
    else if (self.pageSheet == actionSheet){
        
        switch (buttonIndex) {
                
                //Get Pages
            case 1:{
                loadingView.hidden = NO;
                [SCFacebook getPagesCallBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Message
            case 2:{
                loadingView.hidden = NO;
                
                //    Facebook Web address ou pageId
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostForPage:@"633641776679599" message:@"This is message" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Message + Photo
            case 3:{
                loadingView.hidden = NO;
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
                
                //    Facebook Web address ou pageId
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostForPage:@"633641776679599" message:@"This is message with photo" photo:image callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
                
            }
                break;
                
                //Message + Link
            case 4:{
                loadingView.hidden = NO;
                
                //    Facebook Web address ou pageId
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostForPage:@"633641776679599" message:@"This is message" link:@"http://www.lucascorrea.com" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
                
            }
                break;
                
                //Video + title + description
            case 5:{
                loadingView.hidden = NO;
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
                NSData *videoData = [NSData dataWithContentsOfFile:filePath];
                
                //    Facebook Web address ou pageId
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostForPage:@"633641776679599" video:videoData title:@"This is title" description:@"This is description" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                // Admin Message
            case 6:{
                loadingView.hidden = NO;
                
                //    Facebook Web address
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostAdminForPageName:@"Empresa Teste" message:@"This is message" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                // Admin Message + Link
            case 7:{
                loadingView.hidden = NO;
                
                //    Facebook Web address
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostAdminForPageName:@"Empresa Teste" message:@"This is message" link:@"http://www.lucascorrea.com" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
                
            }
                break;
                
                // Admin Message + Photo
            case 8:{
                loadingView.hidden = NO;
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
                
                //    Facebook Web address
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostAdminForPageName:@"Empresa Teste" message:@"This is message" photo:image callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Admin Video + title + description
            case 9:{
                loadingView.hidden = NO;
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
                NSData *videoData = [NSData dataWithContentsOfFile:filePath];
                
                //    Facebook Web address
                //    Example http://www.lucascorrea.com/PageId.png
                [SCFacebook feedPostAdminForPageName:@"Empresa Teste" video:videoData title:@"This is title" description:@"This is description" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
                
            }
                break;
                
            default:
                break;
        }
    }
    
    //Albums
    else if (self.albumSheet == actionSheet){
        
        switch (buttonIndex) {
                
                //Get Albums
            case 1:{
                loadingView.hidden = NO;
                [SCFacebook getAlbumsCallBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Get AlbumId
            case 2:{
                loadingView.hidden = NO;
                [SCFacebook getAlbumById:@"103540609708919" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Get Photos the album
            case 3:{
                loadingView.hidden = NO;
                [SCFacebook getPhotosAlbumById:@"103540609708919" callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Create Album
            case 4:{
                loadingView.hidden = NO;
                [SCFacebook createAlbumName:@"Album test 4" message:@"This is message" privacy: FBAlbumPrivacySelf callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
                //Post Photo in album
            case 5:{
                loadingView.hidden = NO;
                
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.lucascorrea.com/lucas_apple.png"]]];
                [SCFacebook feedPostForAlbumId:@"103540609708919" photo:image callBack:^(BOOL success, id result) {
                    loadingView.hidden = YES;
                    Alert(@"Alert", [result description]);
                }];
            }
                break;
                
            default:
                break;
        }
    }
    
    //Open graph
    else if (self.openGraphSheet == actionSheet){
        switch (buttonIndex) {
            case 1:
                [self openGraph];
                break;
            case 2:
                [self openGraphWithImage];
                break;
                
            default:
                break;
        }
    }
}



#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = self.itemsArray[indexPath.row];
    
    return cell;
}



#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self login];
    }else if (indexPath.row == 1) {
        [self logout];
    }else if (indexPath.row == 2) {
        [self getUserInfo];
    }else if (indexPath.row == 3) {
        [self getFriends];
    }else if (indexPath.row == 4) {
        [self publishYourWall];
    }else if (indexPath.row == 5) {
        [self inviteFriends];
    }else if (indexPath.row == 6) {
        [self publishOpenGraph];
    }else if (indexPath.row == 7) {
        [self publishPageWall];
    }else if (indexPath.row == 8) {
        [self publishAlbums];
    }
}



@end
