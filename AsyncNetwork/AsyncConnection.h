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
#import "AsyncSocket.h"

@class AsyncConnection;

/// AsyncConnection delegate protocol
@protocol AsyncConnectionDelegate <NSObject>
@optional

#pragma mark - AsyncConnectionDelegate
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
- (void)connection:(AsyncConnection *)theConnection didReceiveObject:(id)object tag:(UInt32)tag;
- (void)connection:(AsyncConnection *)theConnection didSendObjectWithTag:(UInt32)tag;
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;

@end

/// The AsyncConnection handles a single socket connection to the target host or net service
@interface AsyncConnection : NSObject <AsyncSocketDelegate, NSNetServiceDelegate> {
	@private
    UInt32 _currentBlockTag;
    NSMutableDictionary *_responseBlocks;
}

@property (readonly) AsyncSocket *socket;
@property (readonly) BOOL connected;

@property (weak) id<AsyncConnectionDelegate> delegate;
@property (readonly) NSNetService *netService; // the target net service (host & port are ignored if set)
@property (readonly) NSString *host;           // the target host
@property (readonly) NSUInteger port;          // the target port
@property (assign) NSTimeInterval timeout;     // connection timeout

+ (NSRunLoop *)networkRunLoop;
+ (id)connectionWithSocket:(AsyncSocket *)socket;
+ (id)connectionWithNetService:(NSNetService *)netService;
+ (id)connectionWithHost:(NSString *)host port:(NSUInteger)port;

- (id)initWithSocket:(AsyncSocket *)theSocket;
- (id)initWithNetService:(NSNetService *)theNetService;
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;

- (void)start;
- (void)cancel;
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;
- (void)sendObject:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;

@end
