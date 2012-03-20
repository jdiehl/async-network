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

#import "ServerController.h"

// private methods
@interface ServerController ()
- (void)updateStatus;
@end

@implementation ServerController

@synthesize server = _server;
@synthesize serviceName = _serviceName;
@synthesize serviceType = _serviceType;
@synthesize listenPort = _listenPort;
@synthesize input = _input;
@synthesize output = _output;
@synthesize status = _status;


// Initialize
- (void)windowDidLoad;
{
	// create and configure the server
	self.server = [AsyncServer new];
	self.server.serviceType = self.serviceType;
	self.server.serviceName = self.serviceName;
	self.server.port = self.listenPort;
	self.server.delegate = self;
	
	// start the server
	[self.server start];
	
	// update the UI
	[self updateStatus];
	self.window.title = self.server.serviceName;
}

// Send the message from the input field to all connected clients
- (IBAction)sendInput:(id)sender;
{
	// ask the server to send the input string to all connected clients
    [self.server sendObject:self.input.stringValue tag:0];
	
	// display log entry
    NSString *string = [NSString stringWithFormat:@">> %@\n", self.input.stringValue];
	[self.output insertText:string];
	
	// clear input
	self.input.stringValue = @"";
}

// Teardown
- (void)dealloc;
{
	[self.server stop];
	self.server.delegate = nil;
}


#pragma mark AsyncServerDelegate

/**
 @brief The server has successfully established a connection to a client.
 @param theServer The server that established the connection
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didConnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<Client connected>\n"];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

/**
 @brief The server was disconnected from a client.
 @param theServer The server that lost the connection
 @param connection The connection that was disconnected
 */
- (void)server:(AsyncServer *)theServer didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<Client disconnected>\n"];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

/**
 @brief The server did receive an object from a client.
 @param theServer The server that received the objet
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"Client: %@\n", object];
	[self.output insertText:string];
}

/**
 @brief The AsyncConnection encountered an error.
 
 Errors can occur in the following situations:
 - In -[AsyncServer start] if the initialization of the AsyncSocket fails
 - Errors are forwarded from all connection objects
 @see AsyncConnectionDelegate
 @param theServer The server that encountered the error
 @param error An object describing the error
 */
- (void)server:(AsyncServer *)theServer didFailWithError:(NSError *)error;
{
	// just display the error
    [self.window presentError:error];
}


#pragma mark private methods

// update status label
- (void)updateStatus;
{
	// display the listening port and connected clients
	self.status.stringValue = [NSString stringWithFormat:@"Listening on port: %d, %d client(s) connected", self.server.port, self.server.connections.count];
}

@end
