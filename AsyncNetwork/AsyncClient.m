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

@implementation AsyncClient

Synthesize(serviceBrowser)
Synthesize(services)
Synthesize(connections)
Synthesize(delegate)
Synthesize(serviceType)
Synthesize(serviceDomain)
Synthesize(autoConnect)


// init
- (id)init;
{
	self = [super init];
	if (self != nil) {
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
	// stop should clean up the net service browser and all open connections
	[self stop];
	
	// clean up
	
	// clean up properties
	
}

// debug description
- (NSString *)description;
{
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s type=%@ services=%d connections=%d>", object_getClassName(self), self.serviceType, self.services.count, self.connections.count];
	AsyncConnection *connection;
	for(connection in self.connections) {
		[string appendFormat:@"\n%\t@", connection.description];
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
		[connection cancel];
	}
	[self.connections removeAllObjects];
}

// send object to all servers
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;
{
	AsyncConnection *connection;
	for (connection in self.connections) {
		if(![connection connected]) continue;
		[connection sendObject:object tag:tag];
	}
}


#pragma mark - NSNetServiceBrowserDelegate

// service browser found new service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	[self.services addObject:netService];
	
	// connect to the net service
	if(self.autoConnect) {
		
		// create and configure a connection
		// the connection takes care of resovling the net service
		AsyncConnection *connection = [AsyncConnection connectionWithNetService:netService];
		connection.delegate = self;
		[connection start];
		[self.connections addObject:connection];
	}	
}

// service browser lost track of a service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	[self.services removeObject:netService];
}


#pragma mark - AsyncConnectionDelegate

// the connection was successfully connected
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	CallOptionalDelegateMethod(client:didConnect:, client:self didConnect:theConnection)
}

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[self.connections removeObject:theConnection];
	CallOptionalDelegateMethod(client:didDisconnect:, client:self didDisconnect:theConnection)
}

// an object was received over this connection
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
{
	CallOptionalDelegateMethod(client:didReceiveObject:tag:fromConnection:, client:self didReceiveObject:object tag:tag fromConnection:theConnection)
}

// an object was sent over this connection
- (void)connection:(AsyncConnection *)theConnection didSendObjectWithTag:(UInt32)tag;
{
	CallOptionalDelegateMethod(client:didSendObjectWithTag:toConnection:, client:self didSendObjectWithTag:tag toConnection:theConnection)
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	CallOptionalDelegateMethod(client:didFailWithError:, client:self didFailWithError:error)
}


@end
