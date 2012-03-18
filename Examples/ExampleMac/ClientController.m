//
//  ClientController.m
//  ExampleMac
//
//  Created by Jonathan Diehl on 26.02.11.
//

#import "ClientController.h"

// private methods
@interface ClientController ()
- (void)updateStatus;
@end

@implementation ClientController

@synthesize serviceType;
@synthesize input, output, status;


// Initialize
- (void)windowDidLoad;
{
	// create the client
	client = [AsyncClient new];
	
	// set the service type
	client.serviceType = self.serviceType;
	
	// make us the delegate
	client.delegate = self;
	
	// start the client
	[client start];
	
	// update the status field
	[self updateStatus];
	
	// retain ourselves (release when window is closed)
	[self retain];
}

// Send the message from the input field to all connected servers
- (IBAction)sendInput:(id)sender;
{
	// ask the client to send the input string to all connected servers
    [client sendObject:input.stringValue tag:0];
	
	// display log entry
    NSString *string = [NSString stringWithFormat:@">> %@\n", input.stringValue];
	[self.output insertText:string];
	
	// clear input
	input.stringValue = @"";
}

// Teardown
- (void)dealloc;
{
	// stop the client
	[client stop];
	
	// remove us as delegate
	client.delegate = nil;
	
	// clean up
	[client release];

	[super dealloc];
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


#pragma mark Notifications

// window was closed
- (void)windowWillClose:(NSNotification *)notification
{
	// we must the release the window controller here or it will never be released
	[self autorelease];
}


#pragma mark private methods

// update the status label
- (void)updateStatus;
{
	// show how many connections we have
	status.stringValue = [NSString stringWithFormat:@"Conntected to %d server(s)", client.connections.count];
}


@end
