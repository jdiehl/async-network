//
//  AppDelegate.m
//  Broadcaster
//
//  Created by Jonathan Diehl on 3/20/12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize broadcaster = _broadcaster;
@synthesize window = _window;
@synthesize output = _output;
@synthesize input = _input;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Create and configure the broadcaster
	self.broadcaster = [AsyncBroadcaster new];
	self.broadcaster.port = kBroadcastPort;
	self.broadcaster.delegate = self;
	
	// start the broadcaster
	[self.broadcaster start];
}

- (IBAction)broadcast:(id)sender
{	
	// get and encode the message from the text field
	NSString *message = self.input.stringValue;
	NSData *encodedMessage = [message dataUsingEncoding:NSUTF8StringEncoding];
	
	// broadcast the encoded message
	[self.broadcaster broadcast:encodedMessage];
	
	// log
	[self.output insertText:[NSString stringWithFormat:@">> %@\n", message]];

	// clear the input text field
	self.input.stringValue = @"";
}


#pragma mark - AsyncBroadcasterDelegate

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
{
	// decode and display the message
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self.output insertText:[NSString stringWithFormat:@"<< [%@:%d] %@\n", host, theBroadcaster.port, message]];
}

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;
{
	[self.output insertText:[NSString stringWithFormat:@"[error] %@\n", error.localizedDescription]];
}

@end
