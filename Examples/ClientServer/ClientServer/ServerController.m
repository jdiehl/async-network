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
@property (weak) IBOutlet NSImageView *imageView;
- (void)updateStatus;
@end

@implementation ServerController

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
    [self.server sendObject:self.input.stringValue];
	
	// display log entry
    NSString *string = [NSString stringWithFormat:@">> %@\n", self.input.stringValue];
	[self.output insertText:string];
	
	// clear input
	self.input.stringValue = @"";
}

- (IBAction)sendImage:(id)sender;
{
    [self.server sendObject:[(NSImageView*)sender image]];
    [self.output insertText:@">> Image"];
}


- (IBAction)clear:(id)sender;
{
    [self.output setString:@""];
}

// Teardown
- (void)dealloc;
{
	[self.server stop];
	self.server.delegate = nil;
}


#pragma mark AsyncServerDelegate

- (void)server:(AsyncServer *)theServer didConnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ connected]\n", connection.host];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

- (void)server:(AsyncServer *)theServer didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ disconnected]\n", connection.host];
	[self.output insertText:string];
	
	// update the status
    [self updateStatus];
}

- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<< [%@] %@\n", connection.host, object];
	[self.output insertText:string];
    
    if ([object isKindOfClass:[NSImage class]]) {
        self.imageView.image = object;
    }
}

- (void)server:(AsyncServer *)theServer didFailWithError:(NSError *)error;
{
	[self.output insertText:[NSString stringWithFormat:@"[error] %@\n", error.localizedDescription]];
}


#pragma mark private methods

// update status label
- (void)updateStatus;
{
	// display the listening port and connected clients
	self.status.stringValue = [NSString stringWithFormat:@"Listening on port: %ld, %ld client(s) connected", self.server.port, self.server.connections.count];
}

@end
