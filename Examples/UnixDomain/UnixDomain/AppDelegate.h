//
//  AppDelegate.h
//  UnixDomain
//
//  Created by Jonathan Diehl on 07.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AsyncNetwork/AsyncNetwork.h>

#import "EchoServer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *inputField;
@property (strong) IBOutlet NSTextView *outputView;
@property (strong) EchoServer *server;

- (IBAction)send:(id)sender;

@end
