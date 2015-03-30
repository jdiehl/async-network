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

#import "AsyncClient.h"
#import "AsyncNetworkHelpers.h"

@implementation AsyncClient

@synthesize serviceBrowser = _serviceBrowser;
@synthesize services = _services;
@synthesize connections = _connections;
@synthesize delegate = _delegate;
@synthesize serviceType = _serviceType;
@synthesize serviceDomain = _serviceDomain;
@synthesize autoConnect = _autoConnect;
@synthesize includesPeerToPeer = _includesPeerToPeer;


// init
- (id)init;
{
	self = [super init];
	if (self != nil) {
		self.includesPeerToPeer = NO;
		self.autoConnect = YES;
		self.serviceType = AsyncNetworkDefaultServiceType;
		self.serviceDomain = AsyncNetworkDefaultServiceDomain;
		_services = [NSMutableSet new];
		_connections = [NSMutableSet new];
	}
	return self;
}

// clean up
- (void)dealloc;
{
	[self stop];
}

// debug description
- (NSString *)description;
{
#ifdef __LP64__
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s type=%@ services=%ld connections=%ld>", object_getClassName(self), self.serviceType, self.services.count, self.connections.count];
#else
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s type=%@ services=%d connections=%d>", object_getClassName(self), self.serviceType, self.services.count, self.connections.count];
#endif

	AsyncConnection *connection;
	for(connection in self.connections) {
		[string appendFormat:@"\n%@\t", connection.description];
	}
	[string appendFormat:@"\n</%s>", object_getClassName(self)];
	return string;
}


#pragma mark - Control Methods

// start the async client automatic service discovery
- (void)start
{
	if (!self.serviceBrowser) {
		_serviceBrowser = [NSNetServiceBrowser new];
		self.serviceBrowser.includesPeerToPeer = self.includesPeerToPeer;
		[self.serviceBrowser setDelegate:self];
		[self.serviceBrowser searchForServicesOfType:self.serviceType inDomain:self.serviceDomain];
	}
}

// stop the async client automatic service discovery
- (void)stop;
{
	// stop net service browser
    if(self.serviceBrowser) {
        [self.serviceBrowser stop];
        _serviceBrowser = nil;
    }
	
	// cancel all open connections
	AsyncConnection *connection;
	for (connection in self.connections) {
		connection.delegate = nil;
		[connection cancel];
	}
	[self.connections removeAllObjects];
	[self.services removeAllObjects];
}

- (void)connectToService:(NSNetService *)service
{
	// create and configure a connection
	// the connection takes care of resovling the net service
	AsyncConnection *connection = [AsyncConnection connectionWithNetService:service];
	connection.delegate = self;
	[connection start];
	[self.connections addObject:connection];
}

// send object to all servers
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	AsyncConnection *connection;
	for (connection in self.connections) {
		if(![connection connected]) continue;
		[connection sendCommand:command object:object responseBlock:block];
	}
}

// send command and object without response block
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object;
{
	[self sendCommand:command object:object responseBlock:nil];
}

// send object with command or response block
- (void)sendObject:(id<NSCoding>)object;
{
	[self sendCommand:0 object:object responseBlock:nil];
}


#pragma mark - NSNetServiceBrowserDelegate

// service browser found new service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	[self.services addObject:netService];
	
	// call delegate
	BOOL connect;
	if ([self.delegate respondsToSelector:@selector(client:didFindService:moreComing:)]) {
		connect = [self.delegate client:self didFindService:netService moreComing:moreComing];
	} else {
		connect = self.autoConnect;
	}
	
	// connect to the net service
	if (connect) {
		[self connectToService:netService];
	}	
}

// service browser lost track of a service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	[self.services removeObject:netService];
	if ([self.delegate respondsToSelector:@selector(client:didRemoveService:)]) {
		[self.delegate client:self didRemoveService:netService];
	}
}


#pragma mark - AsyncConnectionDelegate

// the connection was successfully connected
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	if ([self.delegate respondsToSelector:@selector(client:didConnect:)]) {
		[self.delegate client:self didConnect:theConnection];
	}
}

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[self.connections removeObject:theConnection];
	if ([self.delegate respondsToSelector:@selector(client:didDisconnect:)]) {
		[self.delegate client:self didDisconnect:theConnection];
	}
}

// incomding command
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object;
{
	if ([self.delegate respondsToSelector:@selector(client:didReceiveCommand:object:connection:)]) {
		[self.delegate client:self didReceiveCommand:command object:object connection:theConnection];
	}
}

// incomding request
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	if ([self.delegate respondsToSelector:@selector(client:didReceiveCommand:object:connection:responseBlock:)]) {
		[self.delegate client:self didReceiveCommand:command object:object connection:theConnection responseBlock:block];
	}
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	if ([self.delegate respondsToSelector:@selector(client:didFailWithError:)]) {
		[self.delegate client:self didFailWithError:error];
	}
}


@end
