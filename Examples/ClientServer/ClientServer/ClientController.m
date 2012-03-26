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
    [self.client sendObject:self.input.stringValue];
	
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


#pragma mark - Private Methods

// update the status label
- (void)updateStatus;
{
	// show how many connections we have
	self.status.stringValue = [NSString stringWithFormat:@"Conntected to %d server(s)", self.client.connections.count];
}


#pragma mark - AsyncClientDelegate

- (void)client:(AsyncClient *)theClient didConnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[connected to %@]\n", connection.netService.name];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[disconnected from %@]\n", connection.netService.name];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

- (void)client:(AsyncClient *)theClient didReceiveCommand:(AsyncCommand)command object:(id)object fromConnection:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<< [%@] %@\n", connection.netService.name, object];
	[self.output insertText:string];
}

- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;
{
	[self.output insertText:[NSString stringWithFormat:@"[error] %@\n", error.localizedDescription]];
}


@end
