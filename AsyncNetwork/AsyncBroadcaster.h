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

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "AsyncBroadcasterDelegate.h"

/**
 @brief A broadcaster can send and receive broadcasts to the local network.
 @details 
 @author Jonathan Diehl
 @date 01.04.11
 */
@interface AsyncBroadcaster : NSObject <AsyncUdpSocketDelegate> {
	
@private
	NSTimeInterval timeout;
	NSString *subnet;
    NSUInteger port;
	
    AsyncUdpSocket *listenSocket;
	AsyncUdpSocket *broadcastSocket;
	
    id<AsyncBroadcasterDelegate> delegate;
	
	BOOL ignoreLocalBroadcasts;
}

/// The broadcast timeout (default: 0 = disabled).
@property(assign) NSTimeInterval timeout;

/// The subnet address string to broadcast to (default: 255.255.255.255).
@property(nonatomic, retain) NSString *subnet;

/// The broadcast port (default: 0 = automatic).
@property(assign) NSUInteger port;

/// The local broadcast host (localhost).
@property(readonly) NSString *host;

/// Configure whether local broadcasts are ignored (default: YES).
@property(assign) BOOL ignoreLocalBroadcasts;

/// The delegate.
@property(assign) id<AsyncBroadcasterDelegate> delegate;

/**
 @brief Directly broadcast the given data on the given port.
 
 This is the one method call to sending out broadcasts to the default subnet.
 
 @param data the data to be sent
 @param port the port to send the data from (0 for automatic)
 */
+ (void)broadcast:(NSData *)data onPort:(NSUInteger)port;

/**
 @brief Start the broadcaster.
 
 -= Set up the listening socket
 -= Set up the broadcasting socket
 */
- (void)start;

/**
 @brief Stop the broadcaster and tear down all sockets
 */
- (void)stop;

/**
 @brief Send a broadcast
 
 @param data data to be broadcasted
 @throw Assertion Broadcasting socket not set up
 */
- (void)broadcast:(NSData *)data;

@end
