//
//  BroadcasterController.m
//  Broadcaster
//
//  Created by Jonathan Diehl on 15/03/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

#import "BroadcasterController.h"

@implementation BroadcasterController

- (void)awakeFromNib
{
	// Create and configure the broadcaster
	self.broadcaster = [AsyncBroadcaster new];
	self.broadcaster.port = 50001;
	self.broadcaster.ignoreSelf = NO;
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
	self.output.stringValue = [self.output.stringValue stringByAppendingFormat:@">> %@\n", message];
	
	// clear the input text field
	self.input.stringValue = @"";
}

#pragma mark - AsyncBroadcasterDelegate

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
{
	// decode and display the message
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.output.stringValue = [self.output.stringValue stringByAppendingFormat:@"<< [%@:%ld] %@\n", host, theBroadcaster.port, message];
}

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;
{
	self.output.stringValue = [self.output.stringValue stringByAppendingFormat:@"[error] %@\n", error.localizedDescription];
}


@end
