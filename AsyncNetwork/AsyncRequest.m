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

#import "AsyncRequest.h"
#import "AsyncNetworkConstants.h"

@implementation AsyncRequest

@synthesize netService, host, port, timeout, command, object, responseBlock;

# pragma mark net service requests

// fire a net service request to the given port and call the completion block afterwards
+ (id)fireRequestWithNetService:(NSNetService *)netService command:(UInt32)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithNetService:netService];
	request.command = command;
	request.object = object;
	request.responseBlock = block;
	[request fire];
	return request;
}

// fire a request to the given host and port and call the completion block afterwards
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port command:(UInt32)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithHost:host port:port];
	[request fireWithCompletionBlock:block];
	return request;
}

// create a request from a Bonjour discovery
+ (id)requestWithNetService:(NSNetService *)netService;
{
	return [[[self alloc] initWithNetService:netService] autorelease];
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
	self.responseBlock = block;
	
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
	[connection sendCommand:self.command object:self.object responseBlock:self.responseBlock];
}

// disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
    [connection release];
    [self autorelease];
}

// the server received an object from a client
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)responseObject tag:(UInt32)tag;
{
	// pass the object to the completion block
	if (responseBlock) responseBlock(responseObject, nil);
	
	// disconnect
	[connection cancel];
}

// a client failed with an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	// call the completion block with the error
	if (responseBlock) responseBlock(nil, error);
	
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
	[host release];
	[netService release];
	[responseBlock release];
	[object release];
    [super dealloc];
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s host=%@ port=%d>\n\t%@\n</%s>", object_getClassName(self), host, port, object, object_getClassName(self)];
}


@end
