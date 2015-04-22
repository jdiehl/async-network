//
//  iOSXData.m
//  AsyncNetwork
//
//  Created by Jason Jobe on 4/21/15.
//  Copyright (c) 2015 RWTH. All rights reserved.
//

#import "iOSXData.h"

@interface iOSXData ()
    @property NSString *type;
    @property NSData *data;
@end


@implementation iOSXData

#if !TARGET_OS_IPHONE
NSData *NSImagePNGRepresentation (Image * image) {
    // Create a bitmap representation from the current image
    
    [image lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:Nil];
}
#endif

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _data  = [coder decodeObjectForKey:@"data"];
        _type = [coder decodeObjectForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeObject:self.type forKey:@"type"];
}

- (id)nativeObject {
    [[NSException exceptionWithName:@"Unimplemented Method" reason:@"Subclass MUST override" userInfo:nil] raise];
    return nil;
}

@end


@implementation iOSXImage

- (instancetype)initWithImage:(Image*)image;
{
    self = [super init];
    self.type = @"png";
#if TARGET_OS_IPHONE
    self.data = UIImagePNGRepresentation (image);
#else
    self.data = NSImagePNGRepresentation (image);
#endif
    return self;
}

- (Image*)nativeImage;
{
    // check format
    return [[Image alloc] initWithData:self.data];
}

- (id)nativeObject {
    return [self nativeImage];
}

@end


@implementation iOSXColor
- (instancetype)initWithColor:(Color*)color;
{
    return self;
}
- (Color*)nativeColor {
    return nil;
}

- (id)nativeObject {
    return [self nativeColor];
}

@end


@implementation NSKeyedArchiver (iOSXDataTransport)

+ (NSData*) archivedDataWithRootObject:anObject delegate:(id<NSKeyedArchiverDelegate>)delegate;
{
    NSMutableData *mdata = [NSMutableData new];
    NSKeyedArchiver *arc = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mdata];
    arc.delegate = delegate;
    
    [arc encodeObject:anObject];
    [arc finishEncoding];
    arc.delegate = nil;
    return mdata;
}

@end


@implementation NSKeyedUnarchiver (iOSXDataTransport)

+ unarchiveObjectWithData:(NSData*)data delegate:(id<NSKeyedUnarchiverDelegate>)delegate;
{
    NSKeyedUnarchiver *arc = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    arc.delegate = delegate;
    
    return [arc decodeObject];
}

@end





