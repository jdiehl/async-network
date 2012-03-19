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

@class AsyncServer;
@class AsyncConnection;

/**
 @brief AsyncServer Delegate Protocol.
 @author Jonathan Diehl
 @date 08.03.11
 
 The delegate of an AsyncClient object has the following responsibilities:
 - Respond to successful connection initiation and loss of connection
 - React to incoming objects
 - React to socket errors
 - Acknowledge discovered and lost net services
 */
@protocol AsyncServerDelegate <NSObject>

@optional

#pragma mark AsyncServerDelegate

/**
 @brief The server has successfully established a connection to a client.
 @param theServer The server that established the connection
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didConnect:(AsyncConnection *)connection;

/**
 @brief The server was disconnected from a client.
 @param theServer The server that lost the connection
 @param connection The connection that was disconnected
 */
- (void)server:(AsyncServer *)theServer didDisconnect:(AsyncConnection *)connection;

/**
 @brief The server did receive an object from a client.
 @param theServer The server that received the objet
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;

/**
 @brief The server did send an object to a client.
 @param theServer The server that sent the objet
 @param tag The transaction tag for the object
 @param connection The connection to the client
 */
- (void)server:(AsyncServer *)theServer didSendObjectWithTag:(UInt32)tag toConnection:(AsyncConnection *)connection;

/**
 @brief The AsyncConnection encountered an error.
 
 Errors can occur in the following situations:
 - In -[AsyncServer start] if the initialization of the AsyncSocket fails
 - Errors are forwarded from all connection objects
 @see AsyncConnectionDelegate
 @param theServer The server that encountered the error
 @param error An object describing the error
 */
- (void)server:(AsyncServer *)theServer didFailWithError:(NSError *)error;


@end
