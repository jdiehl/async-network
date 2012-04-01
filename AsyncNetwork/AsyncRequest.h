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

/**
 @brief A request stores a remote host and port, as well as a request body to be sent once a connection was initiated
 @details 
 @author Jonathan Diehl
 @date 25.05.11
 */
@interface AsyncRequest : NSObject <AsyncConnectionDelegate>

@property (readonly) AsyncConnection *connection;

@property (assign) NSTimeInterval timeout;     // connection timeout
@property (assign) AsyncCommand command;       // the command
@property (strong) NSObject<NSCoding> *object; // connection object
@property (copy) AsyncNetworkRequestBlock responseBlock; // connection response block


+ (NSMutableSet *)activeRequests;

+ (id)fireRequestWithNetService:(NSNetService *)netService command:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)block;
+ (id)fireRequestWithHost:(NSString *)host port:(NSUInteger)port command:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)block;
+ (id)requestWithNetService:(NSNetService *)netService;
+ (id)requestWithHost:(NSString *)theHost port:(NSUInteger)thePort;
- (id)initWithNetService:(NSNetService *)netService;
- (id)initWithHost:(NSString *)host port:(NSUInteger)port;
- (void)fire;

@end
