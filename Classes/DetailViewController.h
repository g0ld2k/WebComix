//
//  DetailViewController.h
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Comic.h"
#import "ActionMenuViewController.h"

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIWebViewDelegate> {

    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	Comic *detailItem;
    RootViewController *rootViewController;
	IBOutlet UIWebView *web;
    NSManagedObjectContext *managedObjectContext;
	IBOutlet UIBarButtonItem *toggleIsFavoriteButton;
	NSMutableDictionary *plistDict;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *forwardButton;
    IBOutlet UIBarButtonItem *shareButton;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) Comic *detailItem;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIPopoverController *addComicPopoverController;
@property (nonatomic, retain) UIPopoverController *actionMenuPopoverController;

- (IBAction)insertNewObject:(id)sender;
- (IBAction) toggelFavorite;
- (IBAction) backButtonPressed:(id) sender;
- (IBAction) forwardButtonPressed:(id) sender;
- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;

@end
