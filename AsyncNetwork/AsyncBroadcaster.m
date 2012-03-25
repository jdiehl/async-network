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

// private methods
@interface AsyncBroadcaster ()
- (void)setupListenSocket;
- (void)setupBroadcastSocket;
@end


@implementation AsyncBroadcaster

Synthesize(listenSocket)
Synthesize(broadcastSocket)
Synthesize(delegate)
Synthesize(timeout)
Synthesize(subnet)
Synthesize(port)


// init
- (id)init;
{
    self = [super init];
    if (self) {
        self.subnet = AsyncNetworkBroadcastDefaultSubnet;
		self.timeout = AsyncNetworkBroadcastDefaultTimeout;
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
	return [NSString stringWithFormat:@"<%s port=%d>", object_getClassName(self), self.port];
}


#pragma mark - Control Methods

// open listener and broadcast sockets
- (void)start;
{
	NSAssert(self.port > 0, @"AsyncBroadcaster: invalid port: %d", self.port);
	
	// set up the listen and broadcast sockets
	[self setupListenSocket];
	[self setupBroadcastSocket];
}

// close listener and broadcast sockets
- (void)stop;
{
	// close listen socket
    if (self.listenSocket) {
        [self.listenSocket close];
		self.listenSocket.delegate = nil;
        _listenSocket = nil;
    }
	
	// close the broadcast socket
	if (self.broadcastSocket) {
		[self.broadcastSocket close];
		self.broadcastSocket.delegate = nil;
		_broadcastSocket = nil;
	}
}

// send broadcast data
- (void)broadcast:(NSData *)data;
{
	NSAssert(self.broadcastSocket, @"AsyncBroadcaster: socket not set up");
	if (![self.broadcastSocket sendData:data toHost:self.subnet port:self.port withTimeout:self.timeout tag:0]) {
		NSLog(@"AsyncBroadcaster: failed to send broadcast");
	}
}


#pragma mark - Private Methods

// create the udp listening socket on the given port
- (void)setupListenSocket;
{
	if (self.listenSocket) return;
	
	// set up the udp socket
	_listenSocket = [[AsyncUdpSocket alloc] initIPv4];
	self.listenSocket.delegate = self;
	
	// bind to port
	NSError *error;
	if (![self.listenSocket bindToPort:self.port error:&error]) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
		_listenSocket = nil;
		return;
	}
	
	// start listening
	[self.listenSocket receiveWithTimeout:-1.0 tag:0];
}

// create the udp broadcast socket
- (void)setupBroadcastSocket;
{
	if (self.broadcastSocket) return;

	// set up the udp socket
	_broadcastSocket = [[AsyncUdpSocket alloc] init];
	self.broadcastSocket.delegate = self;
	
	// enable broadcasting
	NSError *error;
	if (![self.broadcastSocket enableBroadcast:YES error:&error]) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
		[self stop];
		return;
	}
}


#pragma mark - AsyncUDPSocketDelegate

/**
 Called when the datagram with the given tag has been sent.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{
	CallOptionalDelegateMethod(broadcasterDidSendData:, broadcasterDidSendData:self);
}

/**
 Called if an error occurs while trying to send a datagram.
 This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
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
	if (AsyncNetworkIPAddressIsLocal(host)) return NO;
	
	// inform delegate
	CallOptionalDelegateMethod(broadcaster:didReceiveData:fromHost:, broadcaster:self didReceiveData:data fromHost:host);
	
	// keep listening
	[self.listenSocket receiveWithTimeout:-1.0 tag:0];

	return YES;
}

/**
 Called if an error occurs while trying to receive a requested datagram.
 This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error;
{
	CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
}

/**
 Called when the socket is closed.
 A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock;
{
	// nothing
}

@end
