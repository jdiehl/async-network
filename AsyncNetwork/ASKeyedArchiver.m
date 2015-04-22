//
//  ASKeyedArchiver.m
//  ClientServer
//
//  Created by Jason Jobe on 4/22/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

/*
    NSKeyedUnarchiver is flawed in that unarchiver:didDecodeObject:
    is NOT called when using the decodeObject for root level decoding
 */

#import "ASKeyedArchiver.h"
#import "iOSXData.h"


@implementation ASKeyedUnarchiver

- (id)decodeObject
{
    id value = [super decodeObject];

    if ([value isKindOfClass:[iOSXData class]]) {
        return [(iOSXData*)value nativeObject];
    }

    if ([self.delegate respondsToSelector:@selector(unarchiver:didDecodeObject:)]) {
        id newValue = [self.delegate unarchiver:self didDecodeObject:value];
        if (newValue) return newValue;
    }
    return value;
}

- (id)decodeObjectForKey:(NSString *)key
{
    id value = [super decodeObjectForKey:key];
    
    if ([value isKindOfClass:[iOSXData class]]) {
        return [(iOSXData*)value nativeObject];
    }
    return value;
}

@end


@implementation ASKeyedArchiver

-(void)encodeObject:(id)object
{
    if ([object isKindOfClass:[Image class]]) {
        object = [[iOSXImage alloc] initWithImage:object];
    }
    else if ([object isKindOfClass:[Color class]]) {
        object = [[iOSXImage alloc] initWithImage:object];
    }
    [super encodeObject:object];
}

- (void)encodeObject:(id)object forKey:(NSString *)key
{
    if ([object isKindOfClass:[Image class]]) {
        object = [[iOSXImage alloc] initWithImage:object];
    }
    else if ([object isKindOfClass:[Color class]]) {
        object = [[iOSXImage alloc] initWithImage:object];
    }
    [super encodeObject:object forKey:key];
}

@end
