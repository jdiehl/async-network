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
#import "AsyncConnection.h"
#import "AsyncNetworkConstants.h"

/**
 @brief A request stores a remote host and port, as well as a request body to be sent once a connection was initiated
 @details 
 @author Jonathan Diehl
 @date 25.05.11
 */
@interface AsyncRequest : NSObject <AsyncConnectionDelegate> {

@private
	// net service
	NSNetService *netService;
	
	// host and port (alternative to address)
    NSString *host;
	NSUInteger port;
	
	// timeout
	NSTimeInterval timeout;
	
	// body
	NSObject<NSCoding> *body;
	
	// request firing
	AsyncConnection *connection;
	AsyncNetworkResponseBlock completionBlock;
}

/// The target host
@property(retain) NSString *host;

/// The target port
@property(assign) NSUInteger port;

/// The target net service (optional)
@property(retain) NSNetService *netService;

/// The request timeout (default: 0)
@property(assign) NSTimeInterval timeout;

/// The request body that will be automatically sent to the host once a connection is established
@property(retain) NSObject<NSCoding> *body;

/**
 @brief Create and fire a request to a Bonjour net service
 @see initWithNetService:
 @see fireWithCompletionBlock:
 */
+ (id)fireRequestWithNetService:(NSNetService *)netService completionBlock:(AsyncNetworkResponseBlock)block;

/**
 @brief Create and fire a request to a host and port
 @see initWithHost:port:
 @see fireWithCompletionBlock:
 */
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port completionBlock:(AsyncNetworkResponseBlock)block;

/**
 @brief Create a request to a Bonjour net service
 @see initWithNetServices:
 */
+ (id)requestWithNetService:(NSNetService *)netService;

/**
 Create and fire a request to a host and port
 @see initWithHost:port:
 */
+ (id)requestWithHost:(NSString *)theHost port:(NSUInteger)thePort;

/**
 @brief Create a request to a Bonjour net service
 @param netService The Bonjour net service
 */ 
- (id)initWithNetService:(NSNetService *)netService;

/**
 @brief Create and fire a request to a host and port
 @param host The host
 @param port The port number
 */
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;

/**
 @brief Fire the request and trigger the completion block once the host has sent a response.
 
 -= Connect via an AsyncConnection object to the host and port or net service
 -= Send the body data to the target host
 -= Wait for a response and trigger the block with the response object
 -= Close the connection
 
 @param block The block to be triggered upon receiving a response
 */
- (void)fireWithCompletionBlock:(AsyncNetworkResponseBlock)block;

@end
