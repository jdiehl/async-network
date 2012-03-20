//
//  ViewController.m
//  MobileClient
//
//  Created by Jonathan Diehl on 3/20/12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)appendLogMessage:(NSString *)text;
@end

@implementation ViewController

@synthesize client = _client;
@synthesize output = _output;
@synthesize input = _input;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// create and configure the client
	self.client = [AsyncClient new];
	self.client.serviceType = kDefaultServiceType;
	self.client.delegate = self;
	
	// start the client
	[self.client start];
	
	[self.input becomeFirstResponder];
}

- (void)dealloc;
{
	[self.client stop];
	self.client.delegate = nil;
	self.client = nil;
	
	self.output = nil;
	self.input = nil;
	[super dealloc];
}

#pragma mark - UITextFieldDelegate

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	// ask the client to send the input string to all connected servers
    [self.client sendObject:self.input.text tag:0];
	
	// display log entry
	NSString *string = [NSString stringWithFormat:@">> %@\n", self.input.text];
	[self appendLogMessage:string];
	
	// clear input
	self.input.text = @"";
	
	return NO;
}

#pragma mark - AsyncClientDelegate

/**
 @brief The client has successfully established a connection to a server.
 @param theClient The client that established the connection
 @param connection The connection to the client
 */
- (void)client:(AsyncClient *)theClient didConnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ connected]\n", connection.netService.name];
	[self appendLogMessage:string];
}

/**
 @brief The client was disconnected from a server.
 @param theClient The client that was disconnected
 @param connection The connection that was disconnected
 */
- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ disconnected]\n", connection.netService.name];
	[self appendLogMessage:string];
}

/**
 @brief The client did receive an object from a server
 @param theClient The client that received the object
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the server
 */
- (void)client:(AsyncClient *)theClient didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<< [%@] %@\n", connection.netService.name, object];
	[self appendLogMessage:string];
}

/**
 @brief The AsyncConnection encountered an error.
 
 Errors are forwarded from all connection objects.
 @see AsyncConnectionDelegate
 @param theClient The client that encountered the error
 @param error An object describing the error
 */
- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;
{
	// log the error
	NSLog(@"Error: %@", error);
}


#pragma mark - private methods

- (void)appendLogMessage:(NSString *)text;
{
    self.output.text = [self.output.text stringByAppendingString:text];
	
	// scroll to bottom
	if (self.output.contentSize.height > self.output.bounds.size.height) {
		[self.output setContentOffset:CGPointMake(0, self.output.contentSize.height - self.output.bounds.size.height) animated:YES];
	}
}


@end
