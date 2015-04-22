//
//  iOSXData.h
//  AsyncNetwork
//
//  Created by Jason Jobe on 4/21/15.
//  Copyright (c) 2015 RWTH. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
@import UIKit;
@compatibility_alias Image UIImage;
@compatibility_alias Color UIColor;
#else
@import AppKit;
@compatibility_alias Image NSImage;
@compatibility_alias Color NSColor;
#endif


@interface iOSXData : NSObject
- nativeObject;
@end

@interface iOSXImage : iOSXData
- (instancetype)initWithImage:(Image*)image;
- (Image*)nativeImage;
@end


@interface iOSXColor : iOSXData
- (instancetype)initWithColor:(Color*)color;
- (Color*)nativeColor;
@end


@interface NSKeyedArchiver (iOSXDataTransport)
+ (NSData*) archivedDataWithRootObject:anObject delegate:(id<NSKeyedArchiverDelegate>)delegate;
@end

@interface NSKeyedUnarchiver (iOSXDataTransport)
+ unarchiveObjectWithData:(NSData*)data delegate:(id<NSKeyedUnarchiverDelegate>)delegate;
@end

