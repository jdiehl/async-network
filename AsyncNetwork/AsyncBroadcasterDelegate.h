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
