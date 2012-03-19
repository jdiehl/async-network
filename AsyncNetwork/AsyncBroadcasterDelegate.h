@class AsyncBroadcaster;

/**
 @brief AsyncBroadcaster Delegate Protocol.
 @author Jonathan Diehl
 @date 01.04.11
 
 The delegate of an AsyncBroadcaster object has the following responsibilities:
 - React to incoming data
 - React to socket errors
 */
@protocol AsyncBroadcasterDelegate <NSObject>

@optional

#pragma mark AsyncBroadcasterDelegate

/**
 @brief The broadcaster received some data from a host.
 @param theBroadcaster The broadcaster that received data
 @param data The data
 @param host The IP address string of the host that the data was received from
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;

/**
 @brief The broadcaster did send data
 @param theBroadcaster The broadcaster that sent the data
 */
- (void)broadcasterDidSendData:(AsyncBroadcaster *)theBroadcaster;

/**
 @brief The AsyncConnection encountered an error.
 
 Errors can occur in the following situations:
 - In -[AsyncConnection start] if the initialization of the broadcast socket fails
 - In -[AsyncConnection start] if the initialization of the listening socket fails
 - If the AsyncUdpSocket reports an error
 
 @param theBroadcaster The broadcaster that encountered the error
 @param error An object describing the error
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;

@end
