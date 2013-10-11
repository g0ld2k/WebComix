    //
//  addComic.m
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//
//Test
#import "addComic.h"
#import "Comic.h"

@implementation addComic

@synthesize BOLComicIsFavorite, managedObjectContext, resultsLabel, currentURL, currentURLTitle;

- (addComic *) initAddComic:(NSString *) url:(NSString *) title
{
	webComiXAppDelegate = (WebComiXAppDelegate *)[[UIApplication sharedApplication] delegate];
	currentURL = url;
	currentURLTitle = title;
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];	
    self.contentSizeForViewInPopover = CGSizeMake(350,225);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	//[txtComicName release];
	//[txtComicURL release];
	[BOLComicIsFavorite release];
	[webComiXAppDelegate release];
	[resultsLabel release];
	[managedObjectContext release];
	[currentURL release];
	[currentURLTitle release];
}

-(void)viewDidAppear:(BOOL)animated 
{
	     // size popover to what you wish, this may change yet aggain?	
}

- (IBAction) addComicButtonPressed:(id)sender
{
	NSString *comicName = txtComicName.text;
	NSString *comicURL = txtComicURL.text;
	
	//NSLog(@"Recieved comic name: %@ with URL: %@", txtComicName.text, txtComicURL.text);
	if ( [ comicURL length ] == 0 )
	{
		resultsLabel.textColor = [ UIColor redColor ];
		resultsLabel.text = @"Missing comic url.";
	}
	else if ( [ comicName length ] == 0 )
	{
		resultsLabel.textColor = [ UIColor redColor ];
		resultsLabel.text = @"Missing comic name.";
	} 
	else
	{
		if ( ! [ [ comicURL substringFromIndex:[ comicURL length ] - 1 ] isEqualToString:@"/" ] )
			comicURL = [ NSString stringWithFormat:@"%@/",comicURL];
		
		if ( ! [ self isURL: comicURL ] )
		{	
			resultsLabel.textColor = [ UIColor redColor ];
			resultsLabel.text = @"URL is not in the proper format (http://example.com)";
		}
		else if ( [ self comicAlreadyExists:comicURL ] )
		{
			resultsLabel.textColor = [ UIColor redColor ];
			resultsLabel.text = @"Comic already exists.";
		}
		else
		{
			Comic *aComic = (Comic *)[NSEntityDescription insertNewObjectForEntityForName:@"Comic" inManagedObjectContext:managedObjectContext];
			aComic.name = comicName;
			aComic.url = comicURL;
			
			if ([BOLComicIsFavorite isOn])
			{
				aComic.isFavorite = [NSNumber numberWithBool:YES];
			}
			
			NSError *error = nil;
			if (![aComic.managedObjectContext save:&error]) {
				// Handle error
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			}
			else {
				resultsLabel.textColor = [UIColor greenColor];
				resultsLabel.text = @"Successfully added";
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
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:managedObjectContext];
		
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

- (IBAction) useCurrentPageDetails:(id)sender
{
	txtComicName.text = currentURLTitle;
	txtComicURL.text = currentURL;
}

- (BOOL) isURL:(NSString *)possibleURL
{
	BOOL retVal = NO;
	if ( possibleURL != nil )
	{
		NSString *regexString = @"(http|https)://(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@!-/]))";
		NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexString];
		retVal = [urlTest evaluateWithObject:possibleURL];
	}
	return retVal;
}

@end
