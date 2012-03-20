//
//  AppDelegate.h
//  Broadcaster
//
//  Created by Jonathan Diehl on 3/20/12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, AsyncBroadcasterDelegate>

@property (retain) AsyncBroadcaster *broadcaster;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *output;
@property (assign) IBOutlet NSTextField *input;

- (IBAction)broadcast:(id)sender;

@end
