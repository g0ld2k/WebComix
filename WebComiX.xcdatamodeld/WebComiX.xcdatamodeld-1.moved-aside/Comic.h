//
//  Comic.h
//  WebComiX
//
//  Created by chris on 3/14/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Comic :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isFavorite;

@end



