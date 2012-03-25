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
#import "AsyncSocket.h"
#import "AsyncNetworkConstants.h"
#import "AsyncConnection.h"
#import "AsyncRequest.h"

// private methods
@interface AsyncClient ()
- (void)setupNetServiceBrowser;
@end


@implementation AsyncClient

@synthesize serviceType, serviceDomain;
@synthesize autoConnect;
@synthesize delegate;

// start the async client automatic service discovery
- (void)start
{
	[self setupNetServiceBrowser];
}

// stop the async client automatic service discovery
- (void)stop;
{
	// close net service browser
    if(netServiceBrowser) {
        [netServiceBrowser stop];
		netServiceBrowser.delegate = nil;
        [netServiceBrowser release];
        netServiceBrowser = nil;
    }
	
	// close all open connections
	for(AsyncConnection *connection in connections) {
		connection.delegate = nil;
		[connection cancel];
	}
	[connections removeAllObjects];
}

// send object to all servers
- (void)sendCommand:(UInt32)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block:(UInt32)tag;
{
	for(AsyncConnection *connection in connections) {
		if(![connection connected]) continue;
		[connection sendCommand:command object:object:object responseBlock:block];
	}
}

// get the connections
- (NSSet *)connections;
{
    return [NSSet setWithSet:connections];
}


#pragma mark private methods

// set up the net service browser
- (void)setupNetServiceBrowser;
{
	// create net service browser if service name is set
    if(!netServiceBrowser){
		
		// set up net service browser and start searching
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [netServiceBrowser setDelegate:self];
        [netServiceBrowser searchForServicesOfType:self.serviceType inDomain:self.serviceDomain];
		
    }
}


#pragma mark NSNetServiceBrowserDelegate

// service browser found new service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	BOOL connect = self.autoConnect;
	
	// inform delegate
	if([self.delegate respondsToSelector:@selector(client:didFindService:moreComing:)]) {
		if([self.delegate client:self didFindService:netService moreComing:moreComing]) connect = YES;
	}
	
	// connect to the net service
	if(connect) {
		
		// create and configure a connection
		// the connection takes care of resovling the net service
		AsyncConnection *connection = [AsyncConnection connectionWithNetService:netService];
		connection.delegate = self;
		[connection start];
		
		// remember the connection
		[connections addObject:connection];
	}
	
}

// service browser lost track of a service
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing;
{
	// inform delegate
	if([self.delegate respondsToSelector:@selector(client:didRemoveService:moreComing:)])
		[self.delegate client:self didRemoveService:netService moreComing:moreComing];
}


#pragma mark AsyncConnectionDelegate

// the connection was successfully connected
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(client:didConnect:)])
        [self.delegate client:self didConnect:theConnection];
}

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[[theConnection retain] autorelease];
	
	// remove from our active connections
	[connections removeObject:theConnection];
	
	// inform delegate
    if([self.delegate respondsToSelector:@selector(client:didDisconnect:)])
        [delegate client:self didDisconnect:theConnection];
}

// an object was received over this connection
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(client:didReceiveObject:tag:fromConnection:)])
        [self.delegate client:self didReceiveObject:object tag:tag fromConnection:theConnection];
}

// an object was sent over this connection
- (void)connection:(AsyncConnection *)theConnection didSendObjectWithTag:(UInt32)tag;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(client:didSendObjectWithTag:toConnection:)])
        [self.delegate client:self didSendObjectWithTag:tag toConnection:theConnection];
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(client:didFailWithError:)])
        [self.delegate client:self didFailWithError:error];
}


#pragma mark memory management

// init
- (id)init;
{
	self = [super init];
	if (self != nil) {
		autoConnect = YES;
		
		// set up the connections set
		connections = [NSMutableSet new];
		
		// net service defaults
		self.serviceType = AsyncNetworkDefaultServiceType;
		self.serviceDomain = AsyncNetworkDefaultServiceDomain;
	}
	return self;
}

// clean up
- (void)dealloc;
{
	// stop should clean up the net service browser and all open connections
	[self stop];
	
	// clean up
	[connections release];
	
	// clean up properties
	[serviceType release];
	[serviceDomain release];
	
	[super dealloc];
}

// debug description
- (NSString *)description;
{
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s serviceType=%@>", object_getClassName(self), serviceType];
	for(AsyncConnection *connection in connections) {
		[string appendFormat:@"\n%\t@", connection.description];
	}
	[string appendFormat:@"\n</%s>", object_getClassName(self)];
	return string;
}


@end
