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
