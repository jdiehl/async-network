//
//  ASKeyedUnarchiver.m
//  ClientServer
//
//  Created by Jason Jobe on 4/22/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

/*
    NSKeyedUnarchiver is flawed in that unarchiver:didDecodeObject:
    is NOT called when using the decodeObject for root level decoding
 */

#import "ASKeyedUnarchiver.h"

@implementation ASKeyedUnarchiver

- (id)decodeObject
{
    id value = [super decodeObject];

    if ([self.delegate respondsToSelector:@selector(unarchiver:didDecodeObject:)]) {
        id newValue = [self.delegate unarchiver:self didDecodeObject:value];
        if (newValue) return newValue;
    }
    return value;
}

- (id)decodeObjectForKey:(NSString *)key
{
    id value = [super decodeObjectForKey:key];
    return value;
}

@end
