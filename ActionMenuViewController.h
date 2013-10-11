//
//  ActionMenuViewController.h
//  WebComiX
//
//  Created by Chris Golding on 4/10/12.
//  Copyright (c) 2012 RabidMonkeyWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

@interface ActionMenuViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *urlToCurrentPage;
@property (nonatomic, strong) NSString *titleOfPage;

- (IBAction)mailLinkToPage:(id)sender;
- (IBAction)tweetLinkToPage:(id)sender;

@end
