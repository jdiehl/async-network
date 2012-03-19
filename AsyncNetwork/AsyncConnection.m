//
//  AsyncConnection.m
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 04.08.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#define AsyncConnectionHeaderSize 8 // 64 bit
#define AsyncConnectionHeaderTag -1

#import "AsyncNetworkConstants.h"
#import "AsyncConnection.h"
#import "AsyncRequest.h"

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
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;
{
	// make sure we do not use a restricted tag
	NSAssert1(tag != AsyncConnectionHeaderTag, @"AsyncConnection: attempted to use a reserved tag: %D", tag);
	
	// make sure there is a connection
	NSAssert(socket != nil, @"AsyncConnection: attempted to send an object without being connected");
	
	// encode data
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
	
	// encode data length
    UInt32 header[2];
	header[0] = CFSwapInt32HostToLittle((UInt32)data.length);
	header[1] = CFSwapInt32HostToLittle(tag);
	
	NSData *dataLength = [NSData dataWithBytes:header length:AsyncConnectionHeaderSize];
	
	// send the data length
	[socket writeData:dataLength withTimeout:timeout tag:AsyncConnectionHeaderTag];
	
	// send data to socket
	[socket writeData:data withTimeout:timeout tag:tag];
}

// send an object with response block
- (void)sendObject:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
{
    // get the key for the block
    if(++currentBlockTag == 0 || currentBlockTag == AsyncConnectionHeaderTag) currentBlockTag = 1000000;
    NSNumber *key = [NSNumber numberWithInteger:currentBlockTag];
    
    // store the block
    [responseBlocks setObject:[[block copy] autorelease] forKey:key];
    
    // send the object
    [self sendObject:object tag:currentBlockTag];
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
	UInt32 header[2];
    id object;
	switch(tag) {
			
		// we have received the length of an object
		// start reading the object
		case AsyncConnectionHeaderTag:
            memcpy(header, data.bytes, AsyncConnectionHeaderSize);
			UInt32 length = CFSwapInt32LittleToHost(header[0]);
			UInt32 dataTag = CFSwapInt32LittleToHost(header[1]);
			[socket readDataToLength:length withTimeout:timeout tag:dataTag];
			break;

		// we have received the object data
		// decode, pass to delegate, and read the next header
		default:
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            // fire a response block if present
            NSNumber *key = [NSNumber numberWithInteger:tag];
            AsyncNetworkResponseBlock block = [responseBlocks objectForKey:key];
            if(block) {
                [[block retain] autorelease];
                [responseBlocks removeObjectForKey:key];
                block(object, nil);
            }
            
            // otherwise: inform delegate
            else {
                if([self.delegate respondsToSelector:@selector(connection:didReceiveObject:tag:)])
                    [self.delegate connection:self didReceiveObject:object tag:(UInt32)tag];

            }
            
            // read the next packet
			[socket readDataToLength:AsyncConnectionHeaderSize withTimeout:timeout tag:AsyncConnectionHeaderTag];
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
		
		// inform delegate that the object was sent
        if([self.delegate respondsToSelector:@selector(connection:didSendObjectWithTag:)])
            [self.delegate connection:self didSendObjectWithTag:(UInt32)tag];
		
	}
}


@end
