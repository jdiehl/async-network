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
#import "GCDAsyncSocket.h"
#import "AsyncConnection.h"

@class AsyncServer;
@class AsyncConnection;

/// AsyncServer delegate protocol
@protocol AsyncServerDelegate <NSObject>
@optional

#pragma mark - AsyncServerDelegate
- (void)server:(AsyncServer *)theServer didConnect:(AsyncConnection *)connection;
- (void)server:(AsyncServer *)theServer didDisconnect:(AsyncConnection *)connection;
- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection;
- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection responseBlock:(AsyncNetworkResponseBlock)block;
- (void)server:(AsyncServer *)theServer didFailWithError:(NSError *)error;

@end

/// A server can accept connections from AsyncConnection objects.
@interface AsyncServer : NSObject <NSNetServiceDelegate, GCDAsyncSocketDelegate, AsyncConnectionDelegate>

@property (readonly) GCDAsyncSocket *listenSocket;
@property (readonly) NSNetService *netService;
@property (readonly) NSMutableSet *connections;

@property (unsafe_unretained) id<AsyncServerDelegate> delegate;
@property (strong) NSString *serviceType;
@property (strong) NSString *serviceDomain;
@property (strong, nonatomic) NSString *serviceName;
@property (assign) NSInteger port;
@property (assign) BOOL includesPeerToPeer;

- (void)start;
- (void)stop;

- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object;
- (void)sendObject:(id<NSCoding>)object;

@end
