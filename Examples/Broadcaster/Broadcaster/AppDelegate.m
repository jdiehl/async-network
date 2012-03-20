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
	self.broadcaster.ignoreLocalBroadcasts = NO;
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

/**
 @brief The broadcaster received some data from a host.
 @param theBroadcaster The broadcaster that received data
 @param data The data
 @param host The IP address string of the host that the data was received from
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
{
	// decode and display the message
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self.output insertText:[NSString stringWithFormat:@"<< [%@:%d] %@\n", host, theBroadcaster.port, message]];
}

/**
 @brief The AsyncConnection encountered an error.
 
 Errors can occur in the following situations:
 - In -[AsyncConnection start] if the initialization of the broadcast socket fails
 - In -[AsyncConnection start] if the initialization of the listening socket fails
 - If the AsyncUdpSocket reports an error
 
 @param theBroadcaster The broadcaster that encountered the error
 @param error An object describing the error
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;
{
	// present the error
	[NSApp presentError:error];
}

@end
