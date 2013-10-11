//
//  xmlReader.m
//  WebComiX
//
//  Created by chris on 3/17/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//

#import "xmlReader.h"
#import "RootViewController.h"
#import "comicPlaceholder.h"
#import "WebComiXAppDelegate.h"

@implementation xmlReader

- (xmlReader *) initxmlReader {
	
	[super init];
	
	appDelegate = (WebComiXAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"comics"]) {
		//Initialize the array.
		appDelegate.comicsFromXML = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"comic"]) {
		
		//Initialize the comic.
		aComic = [[comicPlaceholder alloc] init];
		
		//Extract the attribute here.
		aComic.comicID = [[attributeDict objectForKey:@"id"] integerValue];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if ( string != nil )
	{	
		if(!currentElementValue)
			currentElementValue = [[NSMutableString alloc] initWithString:string];
		else
			[currentElementValue appendString:string];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"comics"])
		return;

	if([elementName isEqualToString:@"comic"]) {
		[appDelegate.comicsFromXML addObject:aComic];
		
		[aComic release];
		aComic = nil;
	}
	else
		[aComic setValue:currentElementValue forKey:elementName];
	
	[currentElementValue release];
	currentElementValue = nil;
}

- (void) dealloc {
	
	[aComic release];
	[currentElementValue release];

	[super dealloc];
}

@end