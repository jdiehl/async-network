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

#import "AsyncNetworkConstants.h"
#import "AsyncConnection.h"
#import "AsyncRequest.h"

#define AsyncConnectionHeaderSize sizeof(AsyncConnectionHeader)
const NSUInteger AsyncConnectionHeaderTag = 1;
const NSUInteger AsyncConnectionBodyTag = 2;

// private functions
NSData *HeaderToData(AsyncConnectionHeader header);
AsyncConnectionHeader DataToHeader(NSData *data);

@implementation AsyncConnection

@synthesize netService;
@synthesize host, port;
@synthesize timeout;
@synthesize delegate;
@synthesize socket;

#pragma mark class methods

// Create and return the run loop used for all network operations
+ (NSRunLoop *)networkRunLoop;
{
	return [NSRunLoop mainRunLoop];
}

// create a new connection with a netservice
+ (id)connectionWithNetService:(NSNetService *)netService;
{
	return [[[self alloc] initWithNetService:netService] autorelease];
}

// create a new connection with a socket
+ (id)connectionWithSocket:(AsyncSocket *)socket;
{
	return [[[self alloc] initWithSocket:socket] autorelease];
}

// create a new connection with host and port
+ (id)connectionWithHost:(NSString *)theHost port:(NSUInteger)thePort;
{
	return [[[self alloc] initWithHost:theHost port:thePort] autorelease];
}


#pragma mark init & clean up

// Init a connection with a netservice
- (id)initWithNetService:(NSNetService *)theNetService;
{
	self = [super init];
	if (self) {
		timeout = AsyncNetworkDefaultConnectionTimeout;
		netService = [theNetService retain];
        responseBlocks = [NSMutableDictionary new];
        currentBlockTag = 1000000;
		
		// read port and host (host may be nil if the net service is not yet resolved
		host = [[netService hostName] retain];
		port = [netService port];
	}
	return self;
}

// Init a connection with a socket
- (id)initWithSocket:(AsyncSocket *)theSocket;
{
	self = [super init];
	if (self) {
		socket = [theSocket retain];
		socket.delegate = self;
		timeout = AsyncNetworkDefaultConnectionTimeout;
        responseBlocks = [NSMutableDictionary new];
        currentBlockTag = 1;
		
		// read port and host
		port = socket.connectedPort;
		host = [socket.connectedHost retain];
	}
	return self;
}

// Init a connection with to a host and port
- (id)initWithHost:(NSString *)theHost port:(NSUInteger)thePort;
{
	return [self initWithHost:theHost port:thePort timeout:AsyncNetworkDefaultConnectionTimeout];
}

// Init a connection with to a host and port
- (id)initWithHost:(NSString *)theHost port:(NSUInteger)thePort timeout:(NSTimeInterval)theTimeout;
{
	self = [super init];
	if (self) {
		host = [theHost retain];
		port = thePort;
		timeout = theTimeout;
        responseBlocks = [NSMutableDictionary new];
        currentBlockTag = 1;
	}
	return self;
}

// Clean up
- (void)dealloc
{
	// stop an active net service resolve
	if(netService.delegate == self) {
		netService.delegate = nil;
		[netService stop];
	}
	[netService release];
	delegate = nil;
	socket.delegate = nil;
	[socket release];
	[host release];
	[responseBlocks release];
	[super dealloc];
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s host=%@ port=%d responseBlocks=%d>", object_getClassName(self), host, port, responseBlocks.count];
}


#pragma mark control actions

// Start the connection by creating a socket to connect to the host and port indicated in the request
- (void)start;
{
	if(socket) return;
	NSError *error;
	
	// resolve the net service if necessary
	if(netService && !host) {
		
		// this will trigger start again once the net service was resolved
		netService.delegate = self;
		[netService resolveWithTimeout:timeout];
		return;
	}
	
	// create the socket
	socket = [AsyncSocket new];
	socket.delegate = self;
	
	// connect to host and port
	if(![socket connectToHost:host onPort:port withTimeout:timeout error:&error]) {
		
		// clean up
		socket.delegate = nil;
		[socket release];
		socket = nil;
		
		// inform delegate
        if([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
            [self.delegate connection:self didFailWithError:error];
		
		return;
	}
}

// Cancel an active connection
- (void)cancel;
{
	[socket disconnect];
}

// are we connected?
- (BOOL)connected;
{
	return socket != nil && [socket connectedHost] != nil;
}

// Archives and object and sends it through the connection
- (void)sendCommand:(UInt32)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
	NSAssert(socket != nil, @"AsyncConnection: attempted to send an object without being connected");
	
	// prepare the header
	AsyncConnectionHeader header;
	header.command = command;
	
	// encode data
	NSData *bodyData = nil;
	if (object) {
		bodyData = [NSKeyedArchiver archivedDataWithRootObject:object];
		header.bodyLength = bodyData.length;
	} else {
		header.bodyLength = 0;
	}
	
	// store response block
	if (block) {
		header.blockTag = ++currentBlockTag;
		[responseBlocks setObject:[[block copy] autorelease] forKey:[NSNumber numberWithInteger:header.blockTag]];
	} else {
		header.blockTag = 0;
	}
	
	// send the header
	NSData *headerData = [NSData dataWithBytes:&header length:AsyncConnectionHeaderSize];
	[socket writeData:headerData withTimeout:timeout tag:AsyncConnectionHeaderTag];
	
	// send the body
	if (header.bodyLength > 0) [socket writeData:bodyData withTimeout:timeout tag:AsyncConnectionBodyTag];
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

// return the connected host
- (NSString *)connectedHost;
{
	return [socket connectedHost];
}


#pragma mark NSNetServiceDelegate

// net service did resolve
- (void)netServiceDidResolveAddress:(NSNetService *)sender;
{
	host = [netService.hostName retain];
	port = netService.port;
	netService.delegate = nil;
	[self start];
}


#pragma mark AsycnSocketDelegate

/**
 Called when a socket connects and is ready for reading and writing.
 The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	// start reading length data
	[socket readDataToLength:AsyncConnectionHeaderSize withTimeout:timeout tag:AsyncConnectionHeaderTag];
	
	// inform delegate that we are connected
    if([self.delegate respondsToSelector:@selector(connectionDidConnect:)])
        [self.delegate connectionDidConnect:self];
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
        if([self.delegate respondsToSelector:@selector(connection:didFailWithError:)])
            [self.delegate connection:self didFailWithError:error];
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
	// inform the delegate that we are disconnected
    if([self.delegate respondsToSelector:@selector(connectionDidDisconnect:)])
        [self.delegate connectionDidDisconnect:self];
}

/**
 Called when a new socket is spawned to handle a connection.  This method should return the run-loop of the
 thread on which the new socket and its delegate should operate. If omitted, [NSRunLoop currentRunLoop] is used.
 **/
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket;
{
	// get the network run loop the class method
    return [[self class] networkRunLoop];
}

/**
 Called when a socket has completed reading the requested data into memory.
 Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    id object;
	switch(tag) {
			
		// store the header and load the body (or next header)
		case AsyncConnectionHeaderTag:
			lastHeader = DataToHeader(data);
			if (lastHeader.bodyLength > 0) {
				[socket readDataToLength:lastHeader.bodyLength withTimeout:timeout tag:AsyncConnectionBodyTag];
			} else {
                if([self.delegate respondsToSelector:@selector(connection:didReceiveCommand:object:)])
                    [self.delegate connection:self didReceiveCommand:lastHeader.command object:nil];
				[socket readDataToLength:AsyncConnectionHeaderSize withTimeout:timeout tag:AsyncConnectionHeaderTag];
			}
			break;

		// we have received the object data
		// decode, pass to delegate, and read the next header
		case AsyncConnectionBodyTag:
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            // fire a response block if present
			if (lastHeader.blockTag > 0) {
				NSNumber *key = [NSNumber numberWithInteger:lastHeader.blockTag];
				AsyncNetworkResponseBlock block = [responseBlocks objectForKey:key];
				[[block retain] autorelease];
				[responseBlocks removeObjectForKey:key];
				block(object, nil);
			}
            
            // otherwise: inform delegate
            else {
                if([self.delegate respondsToSelector:@selector(connection:didReceiveCommand:object:)])
                    [self.delegate connection:self didReceiveCommand:lastHeader.command object:object];
            }
            
            // read the next packet
			[socket readDataToLength:AsyncConnectionHeaderSize withTimeout:timeout tag:AsyncConnectionHeaderTag];
			break;

		// unknown tag
		default:
			NSLog(@"AsyncConnection: ignoring unknown tag: %ld", tag);
	}
}


@end

// convert a header to data
NSData *HeaderToData(AsyncConnectionHeader header)
{
	UInt32 *encodedHeader = malloc(sizeof(AsyncConnectionHeader));
	encodedHeader[0] = CFSwapInt32LittleToHost(header.command);
	encodedHeader[1] = CFSwapInt32LittleToHost(header.blockTag);
	encodedHeader[2] = CFSwapInt32LittleToHost(header.bodyLength);
	return [NSData dataWithBytesNoCopy:encodedHeader length:sizeof(header) freeWhenDone:YES];
}

// convert raw data to a header
AsyncConnectionHeader DataToHeader(NSData *data)
{
	assert(data.length == sizeof(AsyncConnectionHeader));
	
	const UInt32 *encodedHeader = (const UInt32 *)data.bytes;
	AsyncConnectionHeader header;
	header.command = CFSwapInt32LittleToHost(encodedHeader[0]);
	header.blockTag = CFSwapInt32LittleToHost(encodedHeader[1]);
	header.bodyLength = CFSwapInt32LittleToHost(encodedHeader[2]);
	return header;
}