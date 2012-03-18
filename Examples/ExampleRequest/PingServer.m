//
//  PingServer.m
//  ExampleLoader
//
//  Created by Jonathan Diehl on 25.05.11.
//

#import "PingServer.h"

@implementation PingServer


// Initialize
- (id)init
{
    self = [super init];
    if (self) {
		
        // create the server
		server = [AsyncServer new];
		
		// make us the delegate
		server.delegate = self;
		
		// configure the listening port
		server.port = kPingServerPort;
		
		// enable automatic client disconnecting
		server.disconnectClientsAfterSend = YES;
		
		// start the server
		[server start];
    }
    
    return self;
}

// clean up
- (void)dealloc
{
	// shut down server
	[server release];
	
    [super dealloc];
}

#pragma mark AsyncServerDelegate

/**
 @brief The server did receive an object from a client.
 @param theServer The server that received the objet
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;
{
	// construct the response
	NSString *response = [NSString stringWithFormat:@"Received: %@", object];
	
	// send the response
	[connection sendObject:response tag:tag];
}

@end
