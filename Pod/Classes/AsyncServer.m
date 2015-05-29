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


// private methods
@interface AsyncServer ()
- (void)setupListenSocket;
- (void)setupNetService;
@end


@implementation AsyncServer

@synthesize listenSocket = _listenSocket;
@synthesize netService = _netService;
@synthesize connections = _connections;
@synthesize delegate = _delegate;
@synthesize serviceType = _serviceType;
@synthesize serviceDomain = _serviceDomain;
@synthesize serviceName = _serviceName;
@synthesize port = _port;
@synthesize includesPeerToPeer = _includesPeerToPeer;

// init
- (id)init
{
	self = [super init];
	if (self != nil) {
		_connections = [NSMutableSet new];
		self.includesPeerToPeer = NO;
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
#ifdef __LP64__
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s serviceType=%@ serviceName=%@ port=%ld>", object_getClassName(self), self.serviceType, self.serviceName, self.port];
#else
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%s serviceType=%@ serviceName=%@ port=%d>", object_getClassName(self), self.serviceType, self.serviceName, self.port];
#endif
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
		connection.delegate = nil;
		[connection cancel];
	}
	[self.connections removeAllObjects];
}

// send command and object with response block
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	for (AsyncConnection *connection in self.connections) {
		if (![connection connected]) continue;
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
	_listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:AsyncNetworkDispatchQueue()];
	[self.listenSocket setIPv6Enabled:NO];
	NSError *error;
	if (![self.listenSocket acceptOnPort:self.port error:&error]) {
			if ([self.delegate respondsToSelector:@selector(server:didFailWithError:)]) {
				[self.delegate server:self didFailWithError:error];
			}
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
	_netService = [[NSNetService alloc] initWithDomain:self.serviceDomain type:self.serviceType name:self.serviceName port:(int)self.port];

	self.netService.includesPeerToPeer = self.includesPeerToPeer;
    self.netService.delegate = self;
    [self.netService publish];
}


#pragma mark - AsyncConnectionDelegate

// the connection was disconnected
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
{
	[self.connections removeObject:theConnection];
	if ([self.delegate respondsToSelector:@selector(server:didDisconnect:)]) {
		[self.delegate server:self didDisconnect:theConnection];
	}
}

// incoming command
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object;
{
	if ([self.delegate respondsToSelector:@selector(server:didReceiveCommand:object:connection:)]) {
		[self.delegate server:self didReceiveCommand:command object:object connection:theConnection];
	}
}

// incoming request
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	if ([self.delegate respondsToSelector:@selector(server:didReceiveCommand:object:connection:responseBlock:)]) {
		[self.delegate server:self didReceiveCommand:command object:object connection:theConnection responseBlock:block];
	}
}

// the connection reported an error
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;
{
	if ([self.delegate respondsToSelector:@selector(server:didFailWithError:)]) {
		[self.delegate server:self didFailWithError:error];
	}
}


#pragma mark - AsyncSocketDelegate

/**
 * Called when a socket accepts a connection.
 * Another socket is automatically spawned to handle it.
 * 
 * You must retain the newSocket if you wish to handle the connection.
 * Otherwise the newSocket instance will be released and the spawned connection will be closed.
 * 
 * By default the new socket will have the same delegate and delegateQueue.
 * You may, of course, change this at any time.
 **/
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
{
	AsyncConnection *connection = [AsyncConnection connectionWithSocket:newSocket];
	connection.delegate = self;
	[self.connections addObject:connection];
	if ([self.delegate respondsToSelector:@selector(server:didConnect:)]) {
		[self.delegate server:self didConnect:connection];
	}
}


#pragma mark NSNetServiceDelegate

// net service was not published
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
{
	NSError *error = [NSError errorWithDomain:@"NSNetService" code:-1 userInfo:errorDict];
	if ([self.delegate respondsToSelector:@selector(server:didFailWithError:)]) {
		[self.delegate server:self didFailWithError:error];
	}
}


@end
