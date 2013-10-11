//
//  xmlReader.h
//  WebComiX
//
//  Created by chris on 3/17/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//

//#import <Cocoa/Cocoa.h>
#import "Comic.h"

@class WebComiXAppDelegate, comicPlaceholder;

//@interface xmlReader : NSObject {
@interface xmlReader : NSObject <NSXMLParserDelegate> {
	NSMutableString *currentElementValue;
	WebComiXAppDelegate *appDelegate;
	comicPlaceholder *aComic;
}

- (xmlReader *)initxmlReader;

@end
