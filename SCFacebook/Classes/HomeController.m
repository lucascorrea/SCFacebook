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
    [self.itemsArray addObject:@"Event"];
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
            Alert(@"Alert", result);
        }
    }];
}

- (void)login
{
    loadingView.hidden = NO;
    
    [SCFacebook loginCallBack:^(BOOL success, id result) {
        loadingView.hidden = YES;
        if (success) {
            //            [self getUserInfo];
            Alert(@"Alert", @"Success");
        }
    }];
}

- (void)logout
{
    [SCFacebook logoutCallBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", result);
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
            Alert(@"Alert", result);
        }
    }];
}

- (void)publishYourWall
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"Option Publish"
                            delegate:self
                            cancelButtonTitle:nil
                            destructiveButtonTitle:@"Cancel"
                            otherButtonTitles:@"Link", @"Message", @"Photo", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)openGraph
{
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject
                                                      openGraphObjectForPostWithType:@"fblucascorreatest:graphtest"
                                                      title:@"My first post with opengraph"
                                                      image:@"https://fbstatic-a.akamaihd.net/images/devsite/attachment_blank.png"
                                                      url:@"http://www.lucascorrea.com"
                                                      description:@"Description"];
    
    [SCFacebook sendForPostOpenGraphObject:object callBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", result);
        }else{
            Alert(@"Alert", result);
        }
    }];
}

- (void)openGraphWithImage
{
    // instantiate a Facebook Open Graph object
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    // specify that this Open Graph object will be posted to Facebook
    object.provisionedForPost = YES;
    
    // for og:title
    object[@"title"] = @"My first post with opengraph";
    
    // for og:type, this corresponds to the Namespace you've set for your app and the object type name
    object[@"type"] = @"fblucascorreatest:graphtest";
    
    // for og:description
    object[@"description"] = @"Description";
    
    // for og:url, we cover how this is used in the "Deep Linking" section below
    object[@"url"] = @"http://www.lucascorrea.com";
    
    [SCFacebook sendForPostOpenGraphObject:object callBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", result);
        }else{
            Alert(@"Alert", result);
        }
    }];
}


- (void)inviteFriends
{
    [SCFacebook inviteFriendsWithMessage:@"Invite Friends" callBack:^(BOOL success, id result) {
        if (success) {
            Alert(@"Alert", result);
        }else{
            Alert(@"Alert", result);
        }
    }];
}


- (void)eventTest
{
    //Get page info - Name PAGEIOS
    //    633641776679599
    //    Facebook Web address ou pageId
    //    Example http://www.lucascorrea.com/PageId.png
    
    //    [SCFacebook graphFacebookForMethodGET:@"pageios" params:nil callBack:^(BOOL success, id result) {
    //        NSLog(@"%@", result);
    //    }];
    
    
    //POST page - post user PAGEIOS
    //enviando mensagem para pagina
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        [params setObject:@"Event 9 with photo" forKey:@"message"];
//        [SCFacebook graphFacebookForMethodPOST:@"pageios/feed" params:params callBack:^(BOOL success, id result) {
//            NSLog(@"%@", result);
//        }];
    
    //foto com message
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:@"Event 19 with photo" forKey:@"message"];
//    [params setObject:UIImagePNGRepresentation([UIImage imageNamed:@"background.jpg"]) forKey:@"source"];
//    [SCFacebook graphFacebookForMethodPOST:@"pageios/photos" params:params callBack:^(BOOL success, id result) {
//        NSLog(@"%@", result);
//    }];
    
    
    
    //POST page - post adm PAGEIOS or pageID
    //    [SCFacebook userAccountsCallBack:^(BOOL success, id result) {
    //
    //        if (success) {
    //
    //            NSDictionary *dicPageAdmin = nil;
    //
    //            for (NSDictionary *dic in result[@"data"]) {
    //
    //                if ([dic[@"name"] isEqualToString:@"Empresa Teste"]) {
    //                    dicPageAdmin = dic;
    //                    break;
    //                }
    //            }
    //
    //            FBRequest *requestToPost = [[FBRequest alloc] initWithSession:nil
    //                                                                graphPath:@"633641776679599/feed"
    //                                                               parameters:@{@"message" : @"Test 000220", @"access_token" : dicPageAdmin[@"access_token"]}
    //                                                               HTTPMethod:@"POST"];
    //
    //            FBRequestConnection *requestToPostConnection = [[FBRequestConnection alloc] init];
    //            [requestToPostConnection addRequest:requestToPost completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    //                NSLog(@"%@ %@", error, result);
    //            }];
    //
    //            [requestToPostConnection start];
    //        }
    //    }];
    
    
    
    
    //POST  video user
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mp4",
                                   @"Video Test Description2", @"description",
                                   @"Titulo do video2", @"title",nil];

    [SCFacebook graphFacebookForMethodPOST:@"me/videos" params:params callBack:^(BOOL success, id result) {
        NSLog(@"%@", result);
    }];
    

    //POST video in page
//    [SCFacebook userAccountsCallBack:^(BOOL success, id result) {
//        
//        if (success) {
//            
//            NSDictionary *dicPageAdmin = nil;
//            
//            for (NSDictionary *dic in result[@"data"]) {
//                
//                if ([dic[@"name"] isEqualToString:@"Empresa Teste"]) {
//                    dicPageAdmin = dic;
//                    break;
//                }
//            }
//            
//            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mov"];
//            NSData *videoData = [NSData dataWithContentsOfFile:filePath];
//            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                           videoData, @"video.mov",
//                                           @"video/quicktime", @"contentType",
//                                           @"Video Test Description", @"description",
//                                           @"Titulo do video", @"title",
//                                           dicPageAdmin[@"access_token"], @"access_token", nil];
//            
//            FBRequest *requestToPost = [[FBRequest alloc] initWithSession:nil
//                                                                graphPath:@"633641776679599/videos"
//                                                               parameters:params
//                                                               HTTPMethod:@"POST"];
//            
//            FBRequestConnection *requestToPostConnection = [[FBRequestConnection alloc] init];
//            [requestToPostConnection addRequest:requestToPost completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                NSLog(@"%@ %@", error, result);
//            }];
//            
//            [requestToPostConnection start];
//        }
//    }];

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
            //Photo
        case 3:{
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
        [self openGraph];
    }else if (indexPath.row == 7) {
        [self eventTest];
    }
}



@end
