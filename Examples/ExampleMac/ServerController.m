//
//  ServerController.m
//  ExampleMac
//
//  Created by Jonathan Diehl on 13.01.11.
//

#import "ServerController.h"

// private methods
@interface ServerController ()
- (void)updateStatus;
@end

@implementation ServerController

@synthesize serviceName, serviceType, listenPort;
@synthesize input, output, status;


// Initialize
- (void)windowDidLoad;
{
	// create the server
	server = [AsyncServer new];
	
	// configure the Bonjour service type
	server.serviceType = self.serviceType;
	
	// configure the Bonjour service name
	server.serviceName = self.serviceName;
	
	// set the listening port
	server.port = self.listenPort;
	
	// make use the delegate
	server.delegate = self;
	
	// start the server
	[server start];
	
	// update the status
	[self updateStatus];
	
	// update the window title to match the service name
	self.window.title = server.serviceName;
	
	// retain ourselves (release when window is closed)
	[self retain];
}

// Send the message from the input field to all connected clients
- (IBAction)sendInput:(id)sender;
{
	// ask the server to send the input string to all connected clients
    [server sendObject:input.stringValue tag:0];
	
	// display log entry
    NSString *string = [NSString stringWithFormat:@">> %@\n", input.stringValue];
	[self.output insertText:string];
	
	// clear input
	input.stringValue = @"";
}

// Teardown
- (void)dealloc;
{
	// stop the server
	[server stop];
	
	// remove the delegate
	server.delegate = nil;
	
	// clean up
	[server release];
	
	[super dealloc];
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


#pragma mark Notifications

// window was closed
- (void)windowWillClose:(NSNotification *)notification
{
	// we must the release the window controller here or it will never be released
	[self autorelease];
}


#pragma mark private methods

// update status label
- (void)updateStatus;
{
	// display the listening port and connected clients
	status.stringValue = [NSString stringWithFormat:@"Listening on port: %d, %d client(s) connected", server.port, server.connections.count];
}

@end
