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
#import "GCDAsyncUdpSocket.h"

@class AsyncBroadcaster;

/// AsyncBroadcaster Delegate Protocol.
@protocol AsyncBroadcasterDelegate <NSObject>
@optional

#pragma mark - AsyncBroadcasterDelegate

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
- (void)broadcasterDidSendData:(AsyncBroadcaster *)theBroadcaster;
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;

@end


/// A broadcaster can send and receive broadcasts to the local network.
@interface AsyncBroadcaster : NSObject <GCDAsyncUdpSocketDelegate>

@property (readonly) GCDAsyncUdpSocket *listenSocket;
@property (readonly) GCDAsyncUdpSocket *broadcastSocket;

@property (unsafe_unretained) id<AsyncBroadcasterDelegate> delegate;
@property (assign) NSTimeInterval timeout;      // timeout for sending broadcasts, 0 = disabled
@property (strong, nonatomic) NSString *subnet; // default: 255.255.255.255
@property (assign) NSUInteger port;             // must be set to a number > 0
@property (assign) BOOL ignoreSelf;

- (void)start;
- (void)stop;
- (void)broadcast:(NSData *)data;

@end
