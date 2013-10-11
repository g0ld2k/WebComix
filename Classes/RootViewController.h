//
//  RootViewController.h
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WebComiXAppDelegate.h"

@class DetailViewController;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    DetailViewController *detailViewController;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	NSManagedObject *selectedObject;
	WebComiXAppDelegate *webComiXAppDelegate;
	NSMutableDictionary *plistDict;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject:(id)sender;
- (void)insertNewObject:(NSString *) name :(NSString *) url;
- (IBAction)enterEditingMode;
- (IBAction)enterNormalMode;
- (BOOL) comicAlreadyExists :(NSString *) url;
- (void)delete:(NSString*)name:(NSString *)url;

@end
