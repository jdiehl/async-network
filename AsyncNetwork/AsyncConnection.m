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

#import "AsyncConnection.h"
#import "AsyncRequest.h"

#define AsyncConnectionHeaderSize 8 // 64 bit
#define AsyncConnectionHeaderTag -1

@implementation AsyncConnection

Synthesize(socket)
Synthesize(delegate)
Synthesize(timeout)
Synthesize(netService)
Synthesize(host)
Synthesize(port)


// Create and return the run loop used for all network operations
+ (NSRunLoop *)networkRunLoop;
{
	return [NSRunLoop mainRunLoop];
}

// create a new connection with a netservice
+ (id)connectionWithNetService:(NSNetService *)netService;
{
	return [[self alloc] initWithNetService:netService];
}

// create a new connection with a socket
+ (id)connectionWithSocket:(AsyncSocket *)socket;
{
	return [[self alloc] initWithSocket:socket];
}

// create a new connection with host and port
+ (id)connectionWithHost:(NSString *)theHost port:(NSUInteger)thePort;
{
	return [[self alloc] initWithHost:theHost port:thePort];
}


#pragma mark init & clean up

// Init
- (id)init
{
    self = [super init];
    if (self) {
		self.timeout = AsyncNetworkDefaultConnectionTimeout;
        _responseBlocks = [NSMutableDictionary new];
        _currentBlockTag = 0;
    }
    return self;
}

// Init a connection with a netservice
- (id)initWithNetService:(NSNetService *)netService;
{
	self = [self init];
	if (self) {
		_netService = netService;
		_host = self.netService.hostName;
		_port = self.netService.port;
	}
	return self;
}

// Init a connection with a socket
- (id)initWithSocket:(AsyncSocket *)socket;
{
	self = [self init];
	if (self) {
		_socket = socket;
		self.socket.delegate = self;
		_port = self.socket.connectedPort;
		_host = self.socket.connectedHost;
	}
	return self;
}

// Init a connection with to a host and port
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;
{
	self = [self init];
	if (self) {
		_host = host;
		_port = port;
	}
	return self;
}

// Clean up
- (void)dealloc
{
	// stop an active net service resolve
	if (self.netService.delegate == self) {
		self.netService.delegate = nil;
		[self.netService stop];
	}
	self.socket.delegate = nil;
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s host=%@ port=%d requests=%d>", object_getClassName(self), self.host, self.port, _responseBlocks.count];
}


#pragma mark - Control Methods

// Start the connection by creating a socket to connect to the host and port indicated in the request
- (void)start;
{
	if (self.socket) return;
	
	// resolve the net service if necessary
	// this will trigger start again once the net service was resolved
	if (self.netService && !self.host) {
		self.netService.delegate = self;
		[self.netService resolveWithTimeout:self.timeout];
		return;
	}
	
	// create the socket
	_socket = [AsyncSocket new];
	self.socket.delegate = self;
	
	// connect to host and port
	NSError *error;
	if (![self.socket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&error]) {
		CallOptionalDelegateMethod(connection:didFailWithError:, connection:self didFailWithError:error)
		_socket = nil;
		return;
	}
}

// Cancel an active connection
- (void)cancel;
{
	[self.socket disconnect];
	_socket = nil;
}

// are we connected?
- (BOOL)connected;
{
	return (self.socket.connectedHost != nil);
}

// Archives and object and sends it through the connection
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;
{
	// make sure we do not use a restricted tag
	NSAssert1(tag != AsyncConnectionHeaderTag, @"AsyncConnection: attempted to use a reserved tag: %D", tag);
	
	// make sure there is a connection
	NSAssert(self.socket != nil, @"AsyncConnection: attempted to send an object without being connected");
	
	// encode data
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
	
	// encode data length
    UInt32 header[2];
	header[0] = CFSwapInt32HostToLittle((UInt32)data.length);
	header[1] = CFSwapInt32HostToLittle(tag);
	
	NSData *dataLength = [NSData dataWithBytes:header length:AsyncConnectionHeaderSize];
	
	// send the data length
	[self.socket writeData:dataLength withTimeout:self.timeout tag:AsyncConnectionHeaderTag];
	
	// send data to socket
	[self.socket writeData:data withTimeout:self.timeout tag:tag];
}

// send an object with response block
- (void)sendObject:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
    // get the key for the block
    if(++_currentBlockTag == 0 || _currentBlockTag == AsyncConnectionHeaderTag) _currentBlockTag = 1000000;
    NSNumber *key = [NSNumber numberWithInteger:_currentBlockTag];
    
    // store the block
    [_responseBlocks setObject:[block copy] forKey:key];
    
    // send the object
    [self sendObject:object tag:_currentBlockTag];
}

// return the connected host
- (NSString *)connectedHost;
{
	return [self.socket connectedHost];
}


#pragma mark - NSNetServiceDelegate

// net service did resolve
- (void)netServiceDidResolveAddress:(NSNetService *)sender;
{
	_host = self.netService.hostName;
	_port = self.netService.port;
	self.netService.delegate = nil;
	[self start];
}


#pragma mark - AsycnSocketDelegate

/**
 Called when a socket connects and is ready for reading and writing.
 The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	// start reading length data
	[self.socket readDataToLength:AsyncConnectionHeaderSize withTimeout:self.timeout tag:AsyncConnectionHeaderTag];
	
	// inform delegate that we are connected
	CallOptionalDelegateMethod(connectionDidConnect:, connectionDidConnect:self)
}

/**
 In the event of an error, the socket is closed.
 You may call "unreadData" during this call-back to get the last bit of data off the socket.
 When connecting, this delegate method may be called
 before"onSocket:didAcceptNewSocket:" or "onSocket:didConnectToHost:".
 **/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)error;
{
	// inform delegate of the error
	if(error) {
		CallOptionalDelegateMethod(connection:didFailWithError:, connection:self didFailWithError:error)
    }
}

/**
 Called when a socket disconnects with or without error.  If you want to release a socket after it disconnects,
 do so here. It is not safe to do that during "onSocket:willDisconnectWithError:".
 
 If you call the disconnect method, and the socket wasn't already disconnected,
 this delegate method will be called before the disconnect method returns.
 **/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	CallOptionalDelegateMethod(connectionDidDisconnect:, connectionDidDisconnect:self)
}

/**
 Called when a new socket is spawned to handle a connection.  This method should return the run-loop of the
 thread on which the new socket and its delegate should operate. If omitted, [NSRunLoop currentRunLoop] is used.
 **/
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket;
{
    return [[self class] networkRunLoop];
}

/**
 Called when a socket has completed reading the requested data into memory.
 Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
	UInt32 header[2];
    id object;
	switch(tag) {
			
		// we have received the length of an object
		// start reading the object
		case AsyncConnectionHeaderTag:
            memcpy(header, data.bytes, AsyncConnectionHeaderSize);
			UInt32 length = CFSwapInt32LittleToHost(header[0]);
			UInt32 dataTag = CFSwapInt32LittleToHost(header[1]);
			[self.socket readDataToLength:length withTimeout:self.timeout tag:dataTag];
			break;

		// we have received the object data
		// decode, pass to delegate, and read the next header
		default:
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            // fire a response block if present
            NSNumber *key = [NSNumber numberWithInteger:tag];
            AsyncNetworkResponseBlock block = [_responseBlocks objectForKey:key];
            if(block) {
                [_responseBlocks removeObjectForKey:key];
                block(object, nil);
            }
            
            // otherwise: inform delegate
            else {
                if([self.delegate respondsToSelector:@selector(connection:didReceiveObject:tag:)])
                    [self.delegate connection:self didReceiveObject:object tag:(UInt32)tag];

            }
            
            // read the next packet
			[self.socket readDataToLength:AsyncConnectionHeaderSize withTimeout:self.timeout tag:AsyncConnectionHeaderTag];
			break;
	}
}

/**
 Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag;
{
	// we have written an object
	if(tag != AsyncConnectionHeaderTag) {
		CallOptionalDelegateMethod(connection:didSendObjectWithTag:, connection:self didSendObjectWithTag:(UInt32)tag)
	}
}


@end
