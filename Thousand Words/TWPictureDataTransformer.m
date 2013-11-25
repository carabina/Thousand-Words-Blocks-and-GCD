//
//  TWPictureDataTransformer.m
//  Thousand Words
//
//  Created by Eliot Arntz on 11/21/13.
//  Copyright (c) 2013 Code Coalition. All rights reserved.
//

#import "TWPictureDataTransformer.h"

@implementation TWPictureDataTransformer

/* Class method that returns the class of the tranformed value */
+(Class)transformedValueClass
{
    return [NSData class];
}

/* Set the return to YES to allow us to convert the NSData back into a UIImage object */
+(BOOL)allowsReverseTransformation
{
    return YES;
}

/* Converts the UIImage into an NSData object that can be stored in Core Data */
-(id)transformedValue:(id)value
{
    return UIImagePNGRepresentation(value);
}

/* Converts the NSData accessed from Core Data into a UIImage object */
-(id)reverseTransformedValue:(id)value
{
    UIImage *image = [UIImage imageWithData:value];
    return image;
}

@end
