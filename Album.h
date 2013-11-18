//
//  Album.h
//  Thousand Words
//
//  Created by Eliot Arntz on 11/14/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/* Created from the xcdatamodeld file */
@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;

@end
