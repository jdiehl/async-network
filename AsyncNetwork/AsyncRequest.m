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

@synthesize connection = _connection;
@synthesize timeout = _timeout;
@synthesize command = _command;
@synthesize object = _object;
@synthesize responseBlock = _responseBlock;


// active requests
+ (NSSet *)activeRequests;
{
	static NSMutableSet *activeRequests = nil;
	if (!activeRequests) activeRequests = [NSMutableSet new];
	return activeRequests;
}


# pragma mark - Constructors

// fire a net service request to the given port and call the completion block afterwards
+ (id)fireRequestWithNetService:(NSNetService *)netService command:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)block;
{
	AsyncRequest *request = [self requestWithNetService:netService];
	request.command = command;
	request.object = object;
	request.responseBlock = block;
	[request fire];
	return request;
}

// fire a request to the given host and port and call the completion block afterwards
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port command:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)block;
{
	AsyncRequest *request = [self requestWithHost:host port:port];
	request.command = command;
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
		_connection = [[AsyncConnection alloc] initWithNetService:netService];
    }
    return self;
}

// init with host
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;
{
    self = [self init];
    if (self) {
		_connection = [[AsyncConnection alloc] initWithHost:host port:port];
    }
    return self;
}

// debug description
- (NSString *)description;
{
#ifdef __LP64__
	return [NSString stringWithFormat:@"<%s host=%@ port=%ld>", object_getClassName(self), self.connection.host, self.connection.port];
#else
	return [NSString stringWithFormat:@"<%s host=%@ port=%d>", object_getClassName(self), self.connection.host, self.connection.port];
#endif
}


#pragma mark - Responding on Main Thread

// respond (on main thread)
- (void)respondWithObject:(id)response;
{
	self.responseBlock(response, nil);
}

// respond (on main thread)
- (void)respondWithError:(NSError *)error;
{
	self.responseBlock(nil, error);
}


#pragma mark - Control methods

// fire the request and close the connection and call the completion block afterwards
- (void)fire;
{
	[[[self class] activeRequests] addObject:self];
	self.connection.delegate = self;
	[self.connection start];
}


#pragma mark - AsyncClientDelegate

// a new client has connected to the server
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	if (self.command || self.object || self.responseBlock) {
		[self.connection sendCommand:self.command object:self.object responseBlock:^(id response) {
			[self.connection cancel];
			if (self.responseBlock) [self performSelectorOnMainThread:@selector(respondWithObject:) withObject:response waitUntilDone:NO];
		}];
	}
}

// disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[[[self class] activeRequests] removeObject:self];
}

// a client failed with an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	[self.connection cancel];
	if (self.responseBlock) [self performSelectorOnMainThread:@selector(respondWithError:) withObject:error waitUntilDone:NO];
}


@end
