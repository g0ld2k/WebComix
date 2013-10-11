//
//  DetailViewController.m
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright RabidMonkeyWare 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "addComic.h"

@interface DetailViewController ()



- (void) checkWebNaviagationButtons;
- (void)configureView;
- (void)loadURL;
- (void)loadURL:(NSString *) URL;
- (NSString *)configurePlist;
- (BOOL) writePlist;
@end

@implementation DetailViewController

@synthesize toolbar, addComicPopoverController, detailItem, rootViewController, managedObjectContext;

@synthesize actionMenuPopoverController = _actionMenuPopoverController;

#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewObject:(id)sender {



	//if ( addComicPopoverController != nil )
    if ( [self.addComicPopoverController isPopoverVisible] )
    {    
		[addComicPopoverController dismissPopoverAnimated:YES];
    }
	else 
    {
        [rootViewController insertNewObject:sender];	
        addComic *content = [[addComic alloc] init ]; 
        content.currentURL =  web.request.URL.absoluteString;
        content.currentURLTitle = [ web stringByEvaluatingJavaScriptFromString:@"document.title" ];
        content.managedObjectContext = managedObjectContext;
        UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:content];
        aPopover.delegate = self;
        [content release];
        
        // Store the popover in a custom property for later use.
        self.addComicPopoverController = aPopover;
        [aPopover release];
        
        [self.addComicPopoverController presentPopoverFromBarButtonItem:sender
                                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(Comic *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
		
        // Update the view.
        [self configureView];
	}
    
    if ([self.addComicPopoverController isPopoverVisible]) {
        [addComicPopoverController dismissPopoverAnimated:YES];
    }
    if ([self.actionMenuPopoverController isPopoverVisible]) {
        [self.actionMenuPopoverController dismissPopoverAnimated:YES];
    }
}


- (void)configureView {
    // Update the user interface for the detail item.
	Comic *selectedComic = (Comic *)detailItem;
	if ( selectedComic.url.length > 0 )
	{
		[self loadURL];

		if ( ! selectedComic.isFavorite.boolValue ) {
            toggleIsFavoriteButton.tintColor = [UIColor lightGrayColor];   
        }
        else {
            toggleIsFavoriteButton.tintColor = [UIColor darkGrayColor];
        }
		toggleIsFavoriteButton.enabled = YES;
	}
	else
		toggleIsFavoriteButton.enabled = NO;
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Comics";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.addComicPopoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.addComicPopoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}


#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	web.delegate = self;
	
	toggleIsFavoriteButton.enabled = NO;

	NSString *url = [ self configurePlist ];
	if ( url != nil )
	{	
		[ self loadURL:url ];
		[ self checkWebNaviagationButtons ];
	}
}

- (NSString *)configurePlist
{
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"WebComiX.plist"];
	if ( ! [[NSFileManager defaultManager] fileExistsAtPath:path] )
	{
		plistDict = [[NSMutableDictionary alloc] init];
		[ plistDict setObject:@"http://s3.amazonaws.com/rabidmonkeywarexml/index.html" forKey:@"lastAccessed" ];
        [ plistDict setObject:@"TRUE" forKey:@"firstRun" ];
	}
	else
	{
		plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	}
	
	[ self writePlist];
	
	NSString *lastAccessed = [ plistDict objectForKey:@"lastAccessed" ];
	return lastAccessed;
}

- (BOOL) writePlist
{
	NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"WebComiX.plist"];
	BOOL didWrite = [plistDict writeToFile:path atomically:NO];
	
	return didWrite;
}

- (void)viewDidUnload {
	self.addComicPopoverController = nil;
    self.actionMenuPopoverController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	
    [addComicPopoverController release];
    [self.actionMenuPopoverController release];
    [toolbar release];
	[detailItem release];
	[rootViewController release];
	[web release];
	[managedObjectContext release];
    [toggleIsFavoriteButton release];
	[plistDict release];
	[backButton release];
	[forwardButton release];
	
	[super dealloc];
}	

-(void)loadURL:(NSString *) URL
{
	if ( URL != nil && [URL length] > 0 )
	{	
		NSURL *url = [[NSURL alloc] initWithString:URL];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
		[web loadRequest:request];
		[request release];
		[url release];
	}
	[ self checkWebNaviagationButtons ];
}

-(void)loadURL
{
	NSString *URL = [detailItem valueForKey:@"url"];
	if ( URL != nil && [URL length] > 0 )
	{	
		NSURL *url = [[NSURL alloc] initWithString:URL];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
		[web loadRequest:request];
		[ plistDict setObject:URL forKey:@"lastAccessed" ];
		[ self writePlist ];
		[request release];
		[url release];
	}
	//[URL release];
	[ self checkWebNaviagationButtons ];
}

- (IBAction) toggelFavorite
{
	Comic *comicToEdit = (Comic *)detailItem;
   
    NSString *comicToEditURLHost = [[ NSURL URLWithString:comicToEdit.url ] host];
    NSString *currentURLHost = [web.request.URL host];

    //Add www. to url if current url or the comic's url contains www. but the other doesn't
    if ([ currentURLHost hasPrefix:@"www." ] && ! [comicToEditURLHost hasPrefix:@"www."])
    {
        comicToEditURLHost = [NSString stringWithFormat:@"www.%@",comicToEditURLHost];
    }
    else if ( ![currentURLHost hasPrefix:@"www." ] && [comicToEditURLHost hasPrefix:@"www."])
    {
        currentURLHost = [NSString stringWithFormat:@"www.%@", currentURLHost];
    }

    if ( [currentURLHost isEqualToString: comicToEditURLHost] )
    {
        BOOL targetIsFavorite = YES;
        if ( comicToEdit.isFavorite.boolValue )
        {	
            targetIsFavorite = NO;
        }
        
        comicToEdit.isFavorite = [NSNumber numberWithBool:targetIsFavorite];
        NSError *error = nil;
        if ( ![comicToEdit.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        if ( targetIsFavorite ){
            toggleIsFavoriteButton.tintColor = [UIColor darkGrayColor];
        }
        else {
            toggleIsFavoriteButton.tintColor = [UIColor lightGrayColor];
        }
    }
}

- (IBAction) backButtonPressed:(id) sender
{
	[ web goBack ];
}

- (IBAction) forwardButtonPressed:(id) sender
{
	[ web goForward ];
}

- (void) checkWebNaviagationButtons
{
	if ( [ web canGoBack ] )
		backButton.enabled = YES;
	else
		backButton.enabled = NO;
	
	if ( [ web canGoForward ] )
		forwardButton.enabled = YES;
	else
		forwardButton.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[ self checkWebNaviagationButtons ];
	if ( ! [ detailItem.url isEqualToString:web.request.URL.absoluteString ] )
		toggleIsFavoriteButton.enabled = NO;
	else {
		if ( ! toggleIsFavoriteButton.enabled )
			toggleIsFavoriteButton.enabled = YES;
	}
}

- (IBAction)shareButtonPressed:(id)sender
{
    if ( self.actionMenuPopoverController != nil )
	{
        [self.actionMenuPopoverController dismissPopoverAnimated:YES];
        self.actionMenuPopoverController = nil;
    }
	else {
        ActionMenuViewController *content = [[ActionMenuViewController alloc] init ]; 
        content.urlToCurrentPage =  web.request.URL.absoluteString;
        content.titleOfPage = [ web stringByEvaluatingJavaScriptFromString:@"document.title" ];
        UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController:content];
        aPopover.delegate = self;
        [content release];
        
        // Store the popover in a custom property for later use.
        self.actionMenuPopoverController = aPopover;
        [aPopover release];
        
        [self.actionMenuPopoverController presentPopoverFromBarButtonItem:sender
                                                 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)searchButtonPressed:(id)sender {
    NSURL *url = [[NSURL alloc] initWithString:@"http://google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [web loadRequest:request];
    [request release];
    [url release];
}
@end
