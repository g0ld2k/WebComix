//
//  addComic.h
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"
#import "DetailViewController.h"
#import "WebComiXAppDelegate.h"

@class WebComiXAppDelegate;

@interface addComic : UIViewController {
	IBOutlet UITextField *txtComicName;
	IBOutlet UITextField *txtComicURL;
	IBOutlet UISwitch *BOLComicIsFavorite;
	IBOutlet UILabel *resultsLabel;
	NSManagedObjectContext *managedObjectContext;
	WebComiXAppDelegate *webComiXAppDelegate;
	NSString *currentURL;
	NSString *currentURLTitle;
}

@property (nonatomic, retain) UISwitch *BOLComicIsFavorite;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UILabel *resultsLabel;
@property (nonatomic, retain) NSString *currentURL;
@property (nonatomic, retain) NSString *currentURLTitle;

- (IBAction) addComicButtonPressed:(id)sender;
- (IBAction) useCurrentPageDetails:(id)sender;
- (BOOL) comicAlreadyExists :(NSString *) url;
- (addComic *) initAddComic:(NSString *) currentURL:(NSString *) currentTitle;
- (BOOL) isURL:(NSString *)possibleURL;
@end
