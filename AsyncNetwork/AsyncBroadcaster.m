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

#import "AsyncBroadcaster.h"
#import "AsyncNetworkConstants.h"
#import "AsyncNetworkFunctions.h"


@interface AsyncBroadcaster ()
- (void)setupListenSocket;
- (void)setupBroadcastSocket;
@end


@implementation AsyncBroadcaster

@synthesize timeout, subnet, port;
@synthesize ignoreLocalBroadcasts;
@synthesize delegate;

// very generic broadcasting
+ (void)broadcast:(NSData *)data onPort:(NSUInteger)port;
{
	static AsyncUdpSocket *broadcastSocket = nil;
    if(!broadcastSocket) {
		broadcastSocket = [[AsyncUdpSocket alloc] init];
		
		// enable broadcasting
		NSError *error;
		if(![broadcastSocket enableBroadcast:YES error:&error]) {
			NSLog(@"AsyncBroadcaster: Could not enable broadcast on socket: %@", error);
		}
    }
	
	// encode and broadcast data
	if(![broadcastSocket sendData:data toHost:AsyncNetworkBroadcastDefaultSubnet port:port withTimeout:AsyncNetworkBroadcastDefaultTimeout tag:0]) {
		NSLog(@"AsyncBroadcaster: Could not broadcast");
	}
}

// start listening for broadcasts
- (void)start;
{
	NSAssert(self.port > 0, @"AsyncBroadcaster: Set the port to a positive number before starting the broadcaster");
	
	// set up the listen socket
	[self setupListenSocket];
	
	// set up the broadcast socket
	[self setupBroadcastSocket];
}

// stop listening for broadcasts
- (void)stop;
{
	// close listen socket
    if(listenSocket) {
        [listenSocket close];
		[listenSocket setDelegate:nil];
        [listenSocket release];
        listenSocket = nil;
    }
	
	// close the broadcast socket
	if(broadcastSocket) {
		[broadcastSocket close];
		[broadcastSocket setDelegate:nil];
		[broadcastSocket release];
		broadcastSocket = nil;
	}
}

// send broadcast to given port
- (void)broadcast:(NSData *)data;
{
	NSAssert(broadcastSocket, @"AsyncBroadcaster: socket not set up");
	// broadcast data
	if(![broadcastSocket sendData:data toHost:self.subnet port:port withTimeout:self.timeout tag:0]) {
		NSLog(@"AsyncBroadcaster: Could not broadcast");
	}
}


#pragma mark private methods

// create the udp listening socket on the given port
- (void)setupListenSocket;
{
	if(listenSocket) return;
	
	// create listen socket
	listenSocket = [[AsyncUdpSocket alloc] initIPv4];
	listenSocket.delegate = self;
	
	// bind to port
	NSError *error;
	if(![listenSocket bindToPort:self.port error:&error]) {
        if([self.delegate respondsToSelector:@selector(broadcaster:didFailWithError:)])
            [self.delegate broadcaster:self didFailWithError:error];
		
		// clean up
		[listenSocket release];
		listenSocket = nil;
	}
	else {
		// start listening
		[listenSocket receiveWithTimeout:-1.0 tag:0];
	}
}

// create the udp broadcast socket
- (void)setupBroadcastSocket;
{
	if(broadcastSocket) return;

	// set up the udp socket
	broadcastSocket = [[AsyncUdpSocket alloc] init];
	broadcastSocket.delegate = self;
	
	// enable broadcasting
	NSError *error;
	if(![broadcastSocket enableBroadcast:YES error:&error]) {
        if([self.delegate respondsToSelector:@selector(broadcaster:didFailWithError:)])
            [self.delegate broadcaster:self didFailWithError:error];
		
		// clean up
		[self stop];
	}
}


#pragma mark AsyncUDPSocketDelegate

/**
 Called when the datagram with the given tag has been sent.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{
    if([self.delegate respondsToSelector:@selector(broadcasterDidSendData:)])
        [self.delegate broadcasterDidSendData:self];
}

/**
 Called if an error occurs while trying to send a datagram.
 This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
    if([self.delegate respondsToSelector:@selector(broadcaster:didFailWithError:)])
        [delegate broadcaster:self didFailWithError:error];
}

/**
 Called when the socket has received the requested datagram.
 
 Due to the nature of UDP, you may occasionally receive undesired packets.
 These may be rogue UDP packets from unknown hosts,
 or they may be delayed packets arriving after retransmissions have already occurred.
 It's important these packets are properly ignored, while not interfering with the flow of your implementation.
 As an aid, this delegate method has a boolean return value.
 If you ever need to ignore a received packet, simply return NO,
 and AsyncUdpSocket will continue as if the packet never arrived.
 That is, the original receive request will still be queued, and will still timeout as usual if a timeout was set.
 For example, say you requested to receive data, and you set a timeout of 500 milliseconds, using a tag of 15.
 If rogue data arrives after 250 milliseconds, this delegate method would be invoked, and you could simply return NO.
 If the expected data then arrives within the next 250 milliseconds,
 this delegate method will be invoked, with a tag of 15, just as if the rogue data never appeared.
 
 Under normal circumstances, you simply return YES from this method.
 **/
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port;
{
	// ignore messages from ourselves
	if(!self.ignoreLocalBroadcasts || !AsyncNetworkIPAddressIsLocal(host)) {
		
		// inform delegate
        if([self.delegate respondsToSelector:@selector(broadcaster:didReceiveData:fromHost:)])
            [self.delegate broadcaster:self didReceiveData:data fromHost:host];
		
	}
	
	// keep listening
	[listenSocket receiveWithTimeout:-1.0 tag:0];

	return YES;
}

/**
 Called if an error occurs while trying to receive a requested datagram.
 This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error;
{
    if([self.delegate respondsToSelector:@selector(broadcaster:didFailWithError:)])
        [delegate broadcaster:self didFailWithError:error];
}

/**
 Called when the socket is closed.
 A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock;
{
	// nothing
}

// report the host from the listen socket
- (NSString *)host
{
    return [listenSocket localHost];
}


#pragma mark memory management

// init
- (id)init;
{
    self = [super init];
    if (self) {
        self.subnet = AsyncNetworkBroadcastDefaultSubnet;
		self.timeout = AsyncNetworkBroadcastDefaultTimeout;
		self.ignoreLocalBroadcasts = YES;
    }
    return self;
}

// clean up
- (void)dealloc;
{
	[self stop];
	[super dealloc];
}

// debug description
- (NSString *)description;
{
	return [NSString stringWithFormat:@"<%s port=%d>", object_getClassName(self), port];
}

@end
