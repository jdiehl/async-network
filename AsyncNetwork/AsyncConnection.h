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
#import "AsyncNetworkHelpers.h"

@class  AsyncConnection;

typedef UInt32 AsyncCommand;
typedef struct {
	UInt16 type;
	AsyncCommand command;
	UInt32 blockTag;
	UInt32 bodyLength;
} AsyncConnectionHeader;

/// AsyncConnection delegate protocol
@protocol AsyncConnectionDelegate <NSObject>
@optional

#pragma mark - AsyncConnectionDelegate
- (void)connectionDidConnect:(AsyncConnection *)theConnection;
- (void)connectionDidDisconnect:(AsyncConnection *)theConnection;
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object;
- (void)connection:(AsyncConnection *)theConnection didReceiveCommand:(AsyncCommand)command object:(id)object responseBlock:(AsyncNetworkResponseBlock)block;
- (void)connection:(AsyncConnection *)theConnection didFailWithError:(NSError *)error;

@end

/// The AsyncConnection handles a single socket connection to the target host or net service
@interface AsyncConnection : NSObject <GCDAsyncSocketDelegate, NSNetServiceDelegate> {
	@private
	AsyncConnectionHeader _lastHeader;
    UInt32 _currentBlockTag;
    NSMutableDictionary *_responseBlocks;
}

@property (readonly) GCDAsyncSocket *socket;
@property (readonly) BOOL connected;

@property (unsafe_unretained) id<AsyncConnectionDelegate> delegate;
@property (readonly) NSNetService *netService; // the target net service (host & port are ignored if set)
@property (readonly) NSString *host;           // the target host
@property (readonly) NSUInteger port;          // the target port
@property (assign) NSTimeInterval timeout;     // connection timeout

+ (NSRunLoop *)networkRunLoop;

+ (id)connectionWithSocket:(GCDAsyncSocket *)socket;
+ (id)connectionWithNetService:(NSNetService *)netService;
+ (id)connectionWithHost:(NSString *)host port:(NSUInteger)port;

- (id)initWithSocket:(GCDAsyncSocket *)theSocket;
- (id)initWithNetService:(NSNetService *)theNetService;
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;

- (void)start;
- (void)cancel;

- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object;
- (void)sendObject:(id<NSCoding>)object;

@end
