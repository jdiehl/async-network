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

#import "AppDelegate.h"
#import "ClientController.h"
#import "ServerController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize controllers = _controllers;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.controllers = [NSMutableSet new];
	
	// observe window close notifications
	NSNotificationCenter *nfc = [NSNotificationCenter defaultCenter];
	[nfc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
	
	// start a server and a client
	[self newServer:nil];
	[self newClient:nil];
}

// Create a new server
- (IBAction)newServer:(id)sender;
{
	// the server id (increasing number)
	static NSUInteger serverId = 0;
	
	// create and configure the server controller
	ServerController *serverController = [[ServerController alloc] initWithWindowNibName:@"ServerController"];
	serverController.serviceType = kDefaultServiceType;
	serverController.serviceName = [NSString stringWithFormat:@"Server %d", ++serverId];
	[self.controllers addObject:serverController];
	
	// present the controller
	[serverController showWindow:self];
}

// Create a new client
- (IBAction)newClient:(id)sender;
{
	// create and configure the client controller
	ClientController *clientController = [[ClientController alloc] initWithWindowNibName:@"ClientController"];
	clientController.serviceType = kDefaultServiceType;
	[self.controllers addObject:clientController];
	
	// present the controller
	[clientController showWindow:self];
}

// NSWindowWillCloseNotification
- (void)windowWillClose:(NSNotification *)notification;
{
	NSWindow *window = notification.object;
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSWindowController *controller, NSDictionary *bindings) {
		return controller.window != window;
	}];
	[self.controllers filterUsingPredicate:predicate];
}

@end
