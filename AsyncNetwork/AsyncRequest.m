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

@implementation AsyncRequest

Synthesize(connection)
Synthesize(netService)
Synthesize(host)
Synthesize(port)
Synthesize(timeout)
Synthesize(object)
Synthesize(responseBlock)


// active requests
+ (NSSet *)activeRequests;
{
	static NSMutableSet *activeRequests = nil;
	if (!activeRequests) activeRequests = [NSMutableSet new];
	return activeRequests;
}


# pragma mark - Constructors

// fire a net service request to the given port and call the completion block afterwards
+ (id)fireRequestWithNetService:(NSNetService *)netService object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithNetService:netService];
	request.object = object;
	request.responseBlock = block;
	[request fire];
	return request;
}

// fire a request to the given host and port and call the completion block afterwards
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncRequest *request = [self requestWithHost:host port:port];
	request.object = object;
	request.responseBlock = block;
	[request fire];
	return request;
}

// create a request from a Bonjour discovery
+ (id)requestWithNetService:(NSNetService *)netService;
{
	return [[self alloc] initWithNetService:netService];
}

// create a request to the given host and port
+ (id)requestWithHost:(NSString *)host port:(NSUInteger)port;
{
	return [[self alloc] initWithHost:host port:port];
}

// init
- (id)init;
{
    self = [super init];
    if (self) {
		self.timeout = AsyncRequestDefaultTimeout;
    }
    
    return self;
}

// init with address
- (id)initWithNetService:(NSNetService *)netService;
{
    self = [self init];
    if (self) {
		_netService = netService;
    }
    return self;
}

// init with host
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;
{
    self = [self init];
    if (self) {
        _host = host;
		_port = port;
    }
    return self;
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s host=%@ port=%d>", object_getClassName(self), self.host, self.port, object_getClassName(self)];
}


#pragma mark - Control methods

// fire the request and close the connection and call the completion block afterwards
- (void)fire;
{
	if(self.netService) {
		_connection = [[AsyncConnection alloc] initWithNetService:self.netService];
	} else {
		_connection = [[AsyncConnection alloc] initWithHost:self.host port:self.port];
		[self.connection start];
	}
	self.connection.delegate = self;
	
	// the request retains itself as long as the connection is active
	[[[self class] activeRequests] addObject:self];
}


#pragma mark AsyncClientDelegate

// a new client has connected to the server
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	if(self.object) {
		[self.connection sendObject:self.object tag:0];
	}
}

// disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[[[self class] activeRequests] removeObject:self];
}

// the server received an object from a client
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
{
	if (self.responseBlock) self.responseBlock(object, nil);
	[self.connection cancel];
	_connection = nil;
}

// a client failed with an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	if (self.responseBlock) self.responseBlock(nil, error);
	[self.connection cancel];
	_connection = nil;
}


@end
