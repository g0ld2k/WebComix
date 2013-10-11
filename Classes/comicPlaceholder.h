//
//  comicPlaceholder.h
//  WebComiX
//
//  Created by chris on 3/17/10.
//  Copyright 2010 RabidMonkeyWare All rights reserved.
//

//	#import <Cocoa/Cocoa.h>


@interface comicPlaceholder : NSObject {

	NSInteger comicID;
	NSString *name;
	NSString *url;
	NSString *action;
}

@property (nonatomic, readwrite) NSInteger comicID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *action;

@end
