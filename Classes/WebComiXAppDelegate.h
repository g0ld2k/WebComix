//
//  WebComiXAppDelegate.h
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved. 
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "addComic.h"
#import "comicPlaceholder.h"

@class RootViewController;
@class DetailViewController;
@class addComic;

@interface WebComiXAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;

	UISplitViewController *splitViewController;

	RootViewController *rootViewController;
	DetailViewController *detailViewController;
	addComic *addComicController;
	NSMutableArray *comicsFromXML;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet addComic *addComicController;

@property (nonatomic, retain) NSMutableArray *comicsFromXML;

-(void) loadXML;

@end
