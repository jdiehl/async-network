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

#import "AsyncServer.h"
#import "AsyncSocket.h"
#import "AsyncNetworkConstants.h"
#import "AsyncConnection.h"


// private methods
@interface AsyncServer ()
- (void)setupListenSocket;
- (void)setupNetService;
@end


@implementation AsyncServer

@synthesize port;
@synthesize serviceType, serviceDomain, serviceName;
@synthesize disconnectClientsAfterSend;
@synthesize delegate;

// start the async server
- (void)start;
{
	// set up the listen socket
    [self setupListenSocket];
    
    // set up the net service
    [self setupNetService];
}

// stop the async server
- (void)stop;
{
	// close netservice if serviceName is present
    if(netService != nil)
	{
		netService.delegate = nil;
        [netService stop];
        [netService release];
        netService = nil;
    }
	
    
	// close listening socket
    if(listenSocket != nil)
	{
		listenSocket.delegate = nil;
        [listenSocket disconnect];
		[listenSocket release];
        listenSocket = nil;
    }
    
    // close open connections
	for(AsyncConnection *connection in connections) {
		connection.delegate = nil;
		[connection cancel];
	}
	[connections removeAllObjects];
}

- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;
{
	for(AsyncConnection *connection in connections) {
		if(![connection connected]) continue;
		[connection sendObject:object tag:tag];
	}
}

// report connections
- (NSSet *)connections;
{
    return [NSSet setWithSet:connections];
}


#pragma mark accessors

// setting the service name restarts the net service
- (void)setServiceName:(NSString *)theServiceName;
{
	if(![serviceName isEqualToString:theServiceName]) {
		[serviceName release];
		serviceName = [theServiceName retain];
		
		// restart net service
		if(netService) {
			netService.delegate = nil;
			[netService stop];
			[netService release];
			netService = nil;
			
			[self setupNetService];
		}
	}
}


#pragma mark private methods

// set up the listening socket
- (void)setupListenSocket;
{
	// do nothing if the socket is already set up
	if(listenSocket) return;
	
	// create async socket
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	
	// start listening on port
	NSError *error = nil;
	[listenSocket acceptOnPort:port error:&error];
	if(error) {
        if([self.delegate respondsToSelector:@selector(server:didFailWithError:)])
            [self.delegate server:self didFailWithError:error];
	}
	
	// update port
	port = [listenSocket localPort];
}

// set up the net service
- (void)setupNetService;
{
    // do nothing if we do not have a service name
    if(!self.serviceName) return;
    
    // do nothing if we already have a net service
    if(netService) return;
	
    // create and publish net service
	netService = [[NSNetService alloc] initWithDomain:self.serviceDomain type:self.serviceType name:self.serviceName port:(int)port];
    netService.delegate = self;
    [netService publish];
}


#pragma mark AsyncConnectionDelegate

// the connection was successfully connected
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(server:didConnect:)])
        [self.delegate server:self didConnect:theConnection];
}

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[[theConnection retain] autorelease];
	
	// remove from our active connections
	[connections removeObject:theConnection];
	
	// inform delegate
    if([self.delegate respondsToSelector:@selector(server:didDisconnect:)])
        [delegate server:self didDisconnect:theConnection];
}

// an object was received over this connection
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(server:didReceiveObject:tag:fromConnection:)])
        [self.delegate server:self didReceiveObject:object tag:tag fromConnection:theConnection];
}

// an object was sent over this connection
- (void)connection:(AsyncConnection *)theConnection didSendObjectWithTag:(UInt32)tag;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(server:didSendObjectWithTag:toConnection:)])
        [self.delegate server:self didSendObjectWithTag:tag toConnection:theConnection];
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	// inform delegate
    if([self.delegate respondsToSelector:@selector(server:didFailWithError:)])
        [self.delegate server:self didFailWithError:error];
}


#pragma mark AsyncSocketDelegate

/**
 Called when a socket accepts a connection.  Another socket is spawned to handle it. The new socket will have
 the same delegate and will call "onSocket:didConnectToHost:port:".
 **/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	// create a new connection with the socket
	AsyncConnection *connection = [AsyncConnection connectionWithSocket:newSocket];
	connection.delegate = self;
	
	// remember the connection
	[connections addObject:connection];
}

/**
 Called when a new socket is spawned to handle a connection.  This method should return the run-loop of the
 thread on which the new socket and its delegate should operate. If omitted, [NSRunLoop currentRunLoop] is used.
 **/
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket;
{
	return [AsyncConnection networkRunLoop];
}


#pragma mark NSNetServiceDelegate

// not published
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
{
	// inform the delegate
	NSError *error = [NSError errorWithDomain:@"NSNetService" code:-1 userInfo:errorDict];
	[self.delegate server:self didFailWithError:error];
}


#pragma mark memory management

// init
- (id)init
{
	self = [super init];
	if (self != nil) {
		
		// create connections set
		connections = [NSMutableSet new];
		
		// net service defaults
		self.serviceType = AsyncNetworkDefaultServiceType;
		self.serviceDomain = AsyncNetworkDefaultServiceDomain;
	}
	return self;
}

// clean up
- (void)dealloc
{
	// stop should clean up all connections, the netservice, and the listening socket
	[self stop];
	
	// clean up connection handler
	[connections release];
	
	// clean up properties
	[serviceType release];
	[serviceDomain release];
	[serviceName release];
	
	[super dealloc];
}

// debug description
- (NSString *)description;
{
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s serviceType=%@ serviceName=%@ port=%d>", object_getClassName(self), serviceType, serviceName, port];
	for(AsyncConnection *connection in connections) {
		[string appendFormat:@"\n\t%@", connection.description];
	}
	[string appendFormat:@"\n</%s>", object_getClassName(self)];
	return string;
}


@end
