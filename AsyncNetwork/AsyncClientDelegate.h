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

@class AsyncClient;
@class AsyncConnection;

/**
 @brief AsyncClient Delegate Protocol.
 @author Jonathan Diehl
 @date 08.03.11
 
 The delegate of an AsyncClient object has the following responsibilities:
 - Respond to successful connection initiation and loss of connection
 - React to incoming objects
 - React to socket errors
 - Acknowledge discovered and lost net services
 */
@protocol AsyncClientDelegate <NSObject>

@optional

#pragma mark AsyncClientDelegate

/**
 @brief The client has successfully established a connection to a server.
 @param theClient The client that established the connection
 @param connection The connection to the client
 */
- (void)client:(AsyncClient *)theClient didConnect:(AsyncConnection *)connection;

/**
 @brief The client was disconnected from a server.
 @param theClient The client that was disconnected
 @param connection The connection that was disconnected
 */
- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;

/**
 @brief The client did receive an object from a server
 @param theClient The client that received the object
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the server
 */
- (void)client:(AsyncClient *)theClient didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;

/**
 @brief The client did successfully send an object to a server
 @param theClient The client that sent the object
 @param tag The transaction tag
 @param connection The connection to the server
 */
- (void)client:(AsyncClient *)theClient didSendObjectWithTag:(UInt32)tag toConnection:(AsyncConnection *)connection;

/**
 @brief The AsyncConnection encountered an error.
 
 Errors are forwarded from all connection objects.
 @see AsyncConnectionDelegate
 @param theClient The client that encountered the error
 @param error An object describing the error
 */
- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;

/**
 @brief The client discovered a net service that matches its type and domain
 @param theClient The client that discovered the net service
 @param netService The net service that was discovered
 @param moreComing There are more net services that were discovered (this method will be called again)
 @return YES if the client should immediately connect to the net service (this is done anyways if autoconnect is enabled)
 */
- (BOOL)client:(AsyncClient *)theClient didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing;

/**
 @brief A discovered net service is no longer available
 @param theClient The client that discovered the net service
 @param netService The net service that is no longer available
 @param moreComing There are more net services that have become unavailable (this method will be called again)
 */
- (void)client:(AsyncClient *)theClient didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing;

@end
