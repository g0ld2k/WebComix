//
//  WebComiXAppDelegate.m
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved.
//

#import "WebComiXAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "comicPlaceholder.h"
#import "xmlReader.h"

@interface WebComiXAppDelegate (CoreDataPrivate)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSString *)applicationDocumentsDirectory;
@end


@implementation WebComiXAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController, addComicController, comicsFromXML;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    rootViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.managedObjectContext = self.managedObjectContext;

    
	// Add the split view controller's view to the window and display.
	[window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Comic" inManagedObjectContext:managedObjectContext]];
    
    [request setIncludesSubentities:NO];
    
    NSError *err;
    NSUInteger count = [managedObjectContext countForFetchRequest: request error:&err];
    if ( count == NSNotFound || count == 0 )
    {
        [ self loadXML ];
    }
    [request release];
	return YES;
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"WebComiX.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(void) loadXML
{
	NSURL *url = [[NSURL alloc]
				  initWithString:@"http://s3.amazonaws.com/rabidmonkeywarexml/comics.xml"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	//Initilize the delegate
	xmlReader *reader = [[xmlReader alloc] initxmlReader];
	
	//Set delegate
	[xmlParser setDelegate:reader];
	
	//Start parsing the XML file.
	[xmlParser parse];
	
//	if ( success )
//		NSLog(@"No Error");
//	else
//		NSLog(@"Error Error Error!");
	
	NSEnumerator * enumerator = [ comicsFromXML objectEnumerator ];
	comicPlaceholder *aComic;
	while (aComic = [enumerator nextObject]) {
		NSLog(@"Read: %@ %@ %@", aComic.name, aComic.url, aComic.action);
		if ( [ aComic.action isEqualToString:@"Add" ] )
			[ rootViewController insertNewObject:aComic.name :aComic.url ];
		else if ( [ aComic.action isEqualToString:@"Delete" ] )
			[ rootViewController delete:aComic.name :aComic.url ];
	}
	[url release];
	[xmlParser release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[splitViewController release];
	[rootViewController release];
	[detailViewController release];

	[window release];
	[super dealloc];
}


@end

