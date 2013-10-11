//
//  RootViewController.m
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "xmlReader.h"


/*
 This template does not ensure user interface consistency during editing operations in the table view. You must implement appropriate methods to provide the user experience you require.
 */
@interface RootViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RootViewController;

@synthesize detailViewController, fetchedResultsController, managedObjectContext;



#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
	self.view.autoresizesSubviews = YES;
    self.clearsSelectionOnViewWillAppear = NO;
	
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	webComiXAppDelegate = (WebComiXAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[self enterNormalMode];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	detailViewController.managedObjectContext = context;
}

- (void)insertNewObject:(NSString *) name :(NSString *) url
{
	if ( url != nil )
	{
		if ( ! [ [ url substringFromIndex:[ url length ] - 1 ] isEqualToString:@"/" ] )
			url = [ NSString stringWithFormat:@"%@/",url];
		
		if ( ! [ self comicAlreadyExists :url ] )
		{		
			[ self fetchedResultsController ];
			NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
			NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
			Comic *aComic = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

			[ aComic setValue:name forKey:@"name" ];
			[ aComic setValue:url forKey:@"url" ];
			
			// Save the context.
			NSError *error = nil;
			if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			}
		}
	}
}

- (BOOL) comicAlreadyExists :(NSString *) url
{
	BOOL retVal = YES;
	if ( url != nil )
	{	
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		[ fetchRequest setEntity:entity ];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@", url];
		[ fetchRequest setPredicate:predicate ];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];

		if ( [ items count ] == 0 )
			retVal = NO;
		}
	return retVal;
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	Comic *aComic = [fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	if ( aComic.isFavorite.boolValue )
	{
		//UIImage *aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"star" ofType:@"png"]];
        UIImage *aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"black_star_small" ofType:@"png"]];
		cell.imageView.image = aIconImage;
	}
	else {
		cell.imageView.image = nil;
	}

	
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObject *objectToDelete = [fetchedResultsController objectAtIndexPath:indexPath];
        if (detailViewController.detailItem == objectToDelete) {
            detailViewController.detailItem = nil;
        }
        
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:objectToDelete];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }   
}

- (NSMutableArray *)getDeletedComics
{
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"WebComiX.plist"];
	NSMutableArray *deletedComics;
	if ( [[NSFileManager defaultManager] fileExistsAtPath:path] )
	{
		plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		deletedComics = [ plistDict objectForKey:@"deletedComics" ];
	}
	else
		deletedComics = [ NSMutableArray alloc];

	[ paths release ];
	return deletedComics;
}

- (BOOL)recordDeletedComic:(NSString *) comicURL
{
	BOOL didWrite = NO;
	
	if ( comicURL != nil )
	{
		NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"WebComiX.plist"];
		
		NSMutableArray *deletedComics = [ plistDict objectForKey:@"deletedComics" ];
		[ deletedComics  addObject:comicURL ];
		[plistDict setObject:deletedComics forKey:@"deletedComics"];
		
		didWrite = [plistDict writeToFile:path atomically:NO];
	}
	return didWrite;
}

- (void)delete:(NSString*)name:(NSString *)url
{
	if ( url != nil )
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		[ fetchRequest setEntity:entity ];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@ || name = %@", url, name];
		[ fetchRequest setPredicate:predicate ];
		
		NSError *error;
		NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		
		NSEnumerator * e = [ items objectEnumerator ];
		Comic *aComic;
		
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		
		while (aComic = [e nextObject]) {
			[context deleteObject:aComic];
		}
		
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Set the detail item in the detail view controller.
	// NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    detailViewController.detailItem = (Comic *)selectedObject;    
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
	NSSortDescriptor *favSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isFavorite" ascending:NO selector:nil];
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:favSortDescriptor, nameSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];

    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    [aFetchedResultsController release];
    [fetchRequest release];
    [nameSortDescriptor release];
    [favSortDescriptor release];
    [sortDescriptors release];
	
    return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
	[self.tableView reloadData];
}

- (IBAction)enterEditingMode
{
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(enterNormalMode)];
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (IBAction)enterNormalMode
{
	[self.tableView setEditing:NO animated:YES];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self
								   action:@selector(enterEditingMode)];
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
}

-(void) loadXML
{
	UIAlertView *loadXMLAlert = [[UIAlertView alloc] 
								 initWithTitle:@"Update Comic Database"
								 message:@"This action will update the comic database from the server.  Please be patient while the database is being updated."
								delegate:self
								cancelButtonTitle:@"Cancel" 
								 otherButtonTitles:nil];
	[ loadXMLAlert addButtonWithTitle:@"Continue" ];
	[ loadXMLAlert show ];
	[ loadXMLAlert autorelease ];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
		[ webComiXAppDelegate loadXML ];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    
    [detailViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
	[selectedObject release];
	[webComiXAppDelegate release];
    
    [super dealloc];
}

@end
