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
#import "AsyncConnection.h"


// private methods
@interface AsyncServer ()
- (void)setupListenSocket;
- (void)setupNetService;
@end


@implementation AsyncServer

Synthesize(listenSocket)
Synthesize(netService)
Synthesize(connections)
Synthesize(delegate)
Synthesize(serviceType)
Synthesize(serviceDomain)
Synthesize(serviceName)
Synthesize(port)
Synthesize(autoDisconnect)

// init
- (id)init
{
	self = [super init];
	if (self != nil) {
		_connections = [NSMutableSet new];
		self.serviceType = AsyncNetworkDefaultServiceType;
		self.serviceDomain = AsyncNetworkDefaultServiceDomain;
	}
	return self;
}

// clean up
- (void)dealloc
{
	[self stop];
}

// debug description
- (NSString *)description;
{
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s serviceType=%@ serviceName=%@ port=%d>", object_getClassName(self), self.serviceType, self.serviceName, self.port];
	for(AsyncConnection *connection in self.connections) {
		[string appendFormat:@"\n\t%@", connection.description];
	}
	[string appendFormat:@"\n</%s>", object_getClassName(self)];
	return string;
}


#pragma mark - Control Methods

// start the async server
- (void)start;
{
    [self setupListenSocket];
    [self setupNetService];
}

// stop the async server
- (void)stop;
{
	// cancel net service resolve
    if (self.netService) {
        [self.netService stop];
        _netService = nil;
    }
    
	// close listening socket
    if (self.listenSocket) {
        [self.listenSocket disconnect];
        _listenSocket = nil;
    }
    
    // close open connections
	for (AsyncConnection *connection in self.connections) {
		[connection cancel];
	}
	[self.connections removeAllObjects];
}

// send command and object with response block
- (void)sendCommand:(UInt32)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	for (AsyncConnection *connection in self.connections) {
		if (![connection connected]) continue;
		[connection sendCommand:command object:object responseBlock:block];
	}
}

// send command and object without response block
- (void)sendCommand:(UInt32)command object:(id<NSCoding>)object;
{
	[self sendCommand:command object:object responseBlock:nil];
}

// send object with command or response block
- (void)sendObject:(id<NSCoding>)object;
{
	[self sendCommand:0 object:object responseBlock:nil];
}


#pragma mark - Custom Accessors

// setting the service name restarts the net service
- (void)setServiceName:(NSString *)serviceName;
{
	if(![self.serviceName isEqualToString:serviceName]) {
		_serviceName = serviceName;
		if(self.netService) {
			[self.netService stop];
			_netService = nil;
			[self setupNetService];
		}
	}
}


#pragma mark - Private Methods

// set up the listening socket
- (void)setupListenSocket;
{
	if(self.listenSocket) return;
	
	// set up listening socket
	_listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	NSError *error;
	if (![self.listenSocket acceptOnPort:self.port error:&error]) {
		CallOptionalDelegateMethod(server:didFailWithError:, server:self didFailWithError:error);
		_listenSocket = nil;
		return;
	}
	
	// update port from socket
	_port = [self.listenSocket localPort];
}

// set up the net service
- (void)setupNetService;
{
    if(!self.serviceName || self.netService) return;
	
    // create and publish net service
	_netService = [[NSNetService alloc] initWithDomain:self.serviceDomain type:self.serviceType name:self.serviceName port:self.port];
    self.netService.delegate = self;
    [self.netService publish];
}


#pragma mark - AsyncConnectionDelegate

// the connection was successfully connected
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
{
	CallOptionalDelegateMethod(server:didConnect:, server:self didConnect:theConnection)
}

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[self.connections removeObject:theConnection];
	CallOptionalDelegateMethod(server:didDisconnect:, server:self didDisconnect:theConnection)
}

// an object was received over this connection
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object;
{
	CallOptionalDelegateMethod(server:didReceiveCommand:object:fromConnection:, server:self didReceiveCommand:command object:object fromConnection:theConnection)
}

// a request was received over this connection
- (id<NSCoding>)connection:(AsyncConnection *)theConnection respondToCommand:(AsyncCommand)command object:(id)object;
{
	CallAndReturnOptionalDelegateMethod(server:respondToCommand:object:fromConnection:, server:self respondToCommand:command object:object fromConnection:theConnection)
	return nil;
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	CallOptionalDelegateMethod(server:didFailWithError:, server:self didFailWithError:error)
}


#pragma mark - AsyncSocketDelegate

/**
 Called when a socket accepts a connection.  Another socket is spawned to handle it. The new socket will have
 the same delegate and will call "onSocket:didConnectToHost:port:".
 **/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	AsyncConnection *connection = [AsyncConnection connectionWithSocket:newSocket];
	connection.delegate = self;
	[self.connections addObject:connection];
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

// net service was not published
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
{
	NSError *error = [NSError errorWithDomain:@"NSNetService" code:-1 userInfo:errorDict];
	CallOptionalDelegateMethod(server:didFailWithError:, server:self didFailWithError:error)
}


@end
