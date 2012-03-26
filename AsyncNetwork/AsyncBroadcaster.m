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
- (BOOL)setupListenSocket;
- (BOOL)setupBroadcastSocket;
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
	if (![self setupListenSocket]) return;
	if (![self setupBroadcastSocket]) [self stop];
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
	[self.broadcastSocket sendData:data toHost:self.subnet port:self.port withTimeout:self.timeout tag:0];
}


#pragma mark - Private Methods

// create the udp listening socket on the given port
- (BOOL)setupListenSocket;
{
	if (self.listenSocket) return YES;
	
	// set up the udp socket
	_listenSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	[self.listenSocket setIPv6Enabled:NO];
	
	// bind to port
	NSError *error;
	if (![self.listenSocket bindToPort:self.port error:&error]) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
		_listenSocket = nil;
		return NO;
	}
	
	// start listening
	if (![self.listenSocket beginReceiving:&error]) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
		return NO;
	}
	
	return YES;
}

// create the udp broadcast socket
- (BOOL)setupBroadcastSocket;
{
	if (self.broadcastSocket) return YES;

	// set up the udp socket
	_broadcastSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	[self.broadcastSocket setIPv6Enabled:NO];
	
	// enable broadcasting
	NSError *error;
	if (![self.broadcastSocket enableBroadcast:YES error:&error]) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
		return NO;
	}
	
	return YES;
}


#pragma mark - GCDAsyncUdpSocketDelegate

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;
{
	CallOptionalDelegateMethod(broadcasterDidSendData:, broadcasterDidSendData:self);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;
{
	CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;
{
	NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
	if (AsyncNetworkIPAddressIsLocal(host)) return;
	CallOptionalDelegateMethod(broadcaster:didReceiveData:fromHost:, broadcaster:self didReceiveData:data fromHost:host);
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error;
{
	if (error) {
		CallOptionalDelegateMethod(broadcaster:didFailWithError:, broadcaster:self didFailWithError:error);
	}
}

@end
