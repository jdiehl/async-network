/**
 * Copyright (C) 2011 Jonathan Diehl
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 * https://github.com/jdiehl/async-network
 */

#import "ClientController.h"

// private methods
@interface ClientController ()
- (void)updateStatus;
@end

@implementation ClientController

@synthesize client = _client;
@synthesize serviceType = _serviceType;
@synthesize input = _input;
@synthesize output = _output;
@synthesize status = _status;

// Initialize
- (void)windowDidLoad;
{
	// create and configure the client
	self.client = [AsyncClient new];
	self.client.serviceType = self.serviceType;
	self.client.delegate = self;
	
	// start the client
	[self.client start];
	
	// update the UI
	[self updateStatus];
}

// Send the message from the input field to all connected servers
- (IBAction)sendInput:(id)sender;
{
	// ask the client to send the input string to all connected servers
    [self.client sendObject:self.input.stringValue tag:0];
	
	// display log entry
    NSString *string = [NSString stringWithFormat:@">> %@\n", self.input.stringValue];
	[self.output insertText:string];
	
	// clear input
	self.input.stringValue = @"";
}

// Teardown
- (void)dealloc;
{
	[self.client stop];
	self.client.delegate = nil;
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
    NSString *string = [NSString stringWithFormat:@"<%@ connected>\n", connection.netService.name];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

/**
 @brief The client was disconnected from a server.
 @param theClient The client that was disconnected
 @param connection The connection that was disconnected
 */
- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<%@ disconnected>\n", connection.netService.name];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
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
    NSString *string = [NSString stringWithFormat:@"%@: %@\n", connection.netService.name, object];
	[self.output insertText:string];
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
	// just present the error
	[self.window presentError:error];
}


#pragma mark private methods

// update the status label
- (void)updateStatus;
{
	// show how many connections we have
	self.status.stringValue = [NSString stringWithFormat:@"Conntected to %d server(s)", self.client.connections.count];
}


@end
