//
//  AsyncRequest.m
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 25.05.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#import "AsyncRequest.h"
#import "AsyncNetworkConstants.h"

@implementation AsyncRequest

@synthesize netService, host, port, timeout, body;

# pragma mark net service requests

// fire a net service request to the given port and call the completion block afterwards
+ (id)fireRequestWithNetService:(NSNetService *)netService completionBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithNetService:netService];
	[request fireWithCompletionBlock:block];
	return request;
}

// create a request from a Bonjour discovery
+ (id)requestWithNetService:(NSNetService *)netService;
{
	return [[[self alloc] initWithNetService:netService] autorelease];
}

// fire a request to the given host and port and call the completion block afterwards
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port completionBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithHost:host port:port];
	[request fireWithCompletionBlock:block];
	return request;
}

// create a request to the given host and port
+ (id)requestWithHost:(NSString *)host port:(NSUInteger)port;
{
	return [[[self alloc] initWithHost:host port:port] autorelease];
}


#pragma mark fire a request

// fire the request and close the connection and call the completion block afterwards
- (void)fireWithCompletionBlock:(AsyncNetworkResponseBlock)block;
{
	completionBlock = [block copy];
	
	// create connection from net service
	// the connection is started automatically as soon as the net service is resolved
	if(netService) {
		connection = [[AsyncConnection alloc] initWithNetService:netService];
	}
	
	// create and start a connection from host and port
	else {
		connection = [[AsyncConnection alloc] initWithHost:self.host port:self.port timeout:self.timeout];
		[connection start];
	}
	connection.delegate = self;
	
	// the request retains itself as long as the connection is active
	[self retain];
}


#pragma mark AsyncClientDelegate

// a new client has connected to the server
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	if(self.body) {
		[connection sendObject:self.body tag:0];
	}
}

// disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
    [connection release];
    [self autorelease];
}

// the server received an object from a client
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
{
	// pass the object to the completion block
	completionBlock(object, nil);
	
	// disconnect
	[connection cancel];
}

// a client failed with an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	// call the completion block with the error
	completionBlock(nil, error);
	
	// disconnect
	[connection cancel];
}



#pragma mark init & clean up

// init with address
- (id)initWithNetService:(NSNetService *)theNetService;
{
    self = [self init];
    if (self) {
		netService = [theNetService retain];
    }
    return self;
}

// init with host
- (id)initWithHost:(NSString *)theHost port:(NSUInteger)thePort;
{
    self = [self init];
    if (self) {
        host = [theHost retain];
		port = thePort;
    }
    return self;
}

// designated init
- (id)init;
{
    self = [super init];
    if (self) {
		timeout = AsyncRequestDefaultTimeout;
    }
    
    return self;
}

// clean up
- (void)dealloc
{
	[completionBlock release];
	[host release];
	[netService release];
	[body release];
    [super dealloc];
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s host=%@ port=%d>\n\t%@\n</%s>", object_getClassName(self), host, port, body, object_getClassName(self)];
}


@end