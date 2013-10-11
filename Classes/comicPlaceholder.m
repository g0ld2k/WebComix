//
//  comicPlaceholder.m
//  WebComiX
//
//  Created by chris on 3/17/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//

#import "comicPlaceholder.h"


@implementation comicPlaceholder

@synthesize name, url, action, comicID;

-(void) dealloc
{
	[name release];
	[url release];
	[action release];
	[super dealloc];
}
@end
