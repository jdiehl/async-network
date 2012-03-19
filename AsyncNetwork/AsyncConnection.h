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
#import "AsyncConnectionDelegate.h"
#import "AsyncNetworkConstants.h"

/**
 @brief Handles a single connection to a target host.
 @details 
 @author Jonathan Diehl
 @date 04.08.11
 */
@interface AsyncConnection : NSObject <AsyncSocketDelegate, NSNetServiceDelegate> {
	
@private
	NSNetService *netService;
	NSString *host;
	NSUInteger port;
	AsyncSocket *socket;
	NSTimeInterval timeout;
    UInt32 currentBlockTag;
    NSMutableDictionary *responseBlocks;
	id<AsyncConnectionDelegate> delegate;
}

/// The connection timeout in seconds.
@property(assign) NSTimeInterval timeout;

/// The delegate.
@property(assign) id<AsyncConnectionDelegate> delegate;

/// A net service that describes the host to connect to (optional).
@property(readonly) NSNetService *netService;

/// The target host IP address or DNS string.
@property(readonly) NSString *host;

/// The target host port number.
@property(readonly) NSUInteger port;

/// The socket that handles the connection to the target.
@property(readonly) AsyncSocket *socket;

/// Determine whether the connection was successfully established.
@property(readonly) BOOL connected;

/**
 @brief Set up the run loop that is used for network operations.
 @return The run loop object
 @todo This should be changed to a delegate call with a useful fallback (separate network thread) - currently this just uses the main run loop
 */
+ (NSRunLoop *)networkRunLoop;


/**
 @brief Create a new connection with an existing socket
 @see initWithSocket:
 */
+ (id)connectionWithSocket:(AsyncSocket *)socket;

/**
 @brief Create a new connection with a Bonjour net service.
 @see initWithetService:
 */
+ (id)connectionWithNetService:(NSNetService *)netService;

/**
 @brief Create a new connection with a host string and port number.
 @see initWithHost:port:
 */
+ (id)connectionWithHost:(NSString *)host port:(NSUInteger)port;

/**
 @brief Create a new connection with an existing socket
 
 This method should only be used by the AsyncServer to spawn connection objects for a listening socket.
 @param socket The existing socket
 @return The connection object
 */
- (id)initWithSocket:(AsyncSocket *)theSocket;

/**
 @brief Create a new connection with a Bonjour net service.
 
 This method should only be used by the AsyncServer to spawn connection objects for a listening socket.
 @param netService The netService
 @return The connection object
 */
- (id)initWithNetService:(NSNetService *)theNetService;

/**
 @brief Create a new connection with a host string and port number.
 
 The net service is automatically resolved if necessary.
 @param socket The existing socket
 @return The connection object
 */
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;

/**
 @brief Create a new connection with an existing socket
 
 This is an alternative to initWithNetService: if you do not want to use Bonjour.
 @param host The host string
 @param port The port number
 @return The connection object
 */
- (id)initWithHost:(NSString *)host port:(NSUInteger)port timeout:(NSTimeInterval)timeout;

/**
 @brief Initiate the connection.
 
 -# Resolve the net service if necessary (this will fill the host and port properties)
 -# Create an AsycnSocket to connect to the host and port
 -# Initiate the socket connection
 
 This method does nothing if there is a socket (e.g., by calling initWithSocket:)
 */
- (void)start;

/**
 @brief Cancel an active connection.
 
 This method does nothing if there is no socket
 */
- (void)cancel;

/**
 @brief Send and object to the target host.
 
 -# The object is encoded using NSCoding
 -# The data length (32bit int) is sent to the target host with tag MAXINT
 -# The object data is sent to the target host with the given tag.
 
 Tags are used to identify coherent transactions. The other end receives the tag alongside the data and can respond
 with the same or a different tag. You may use any positive number as a tag except for MAXINT (-1).
 @throw Assertion Socket was not created
 @throw Assertion Reserved tag was used
 @param object The object to be sent
 @param tag The transaction tag
 */
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;

/**
 @brief Send and object to the target host and await a response.
 
 The object is send with an automatically determined tag (above 1000000) as in sendObject:tag:. Once the target responds
 with the same tag, the given block is triggered with the response.
 
 There are two things to note:
 - Make sure that the target responds with the same tag or the block will never be triggered and released
 - If you want to mix both sending methods, do not use tags above 1000000 for regular object sending.
 
 @see sendObject:tag:
 @throw Assertion Socket was not created
 @param object The object to be sent
 @param block The block that will be triggered once a response was received
 */
- (void)sendObject:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;


@end
