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
#import <dispatch/dispatch.h>


#pragma mark - Public Constants

/// The standard network response block
typedef void (^AsyncNetworkResponseBlock)(id<NSCoding> response);
typedef void (^AsyncNetworkRequestBlock)(id<NSCoding> response, NSError *error);

/// The local loopback address
extern NSString * AsyncNetworkLocalHost;

/// Default net service type for the AsyncServer
extern NSString *AsyncNetworkDefaultServiceType;

/// Default net service domain for the AsyncServer
extern NSString *AsyncNetworkDefaultServiceDomain;

/// Default connection timeout for the AsyncConnection
extern const NSTimeInterval AsyncNetworkDefaultConnectionTimeout;

/// Default net service resolve timeout for the AsyncConnection
extern const NSTimeInterval AsyncNetworkDefaultResolveTimeout;

/// Default broadcasting address for the AsyncBroadcaster
extern NSString *AsyncNetworkBroadcastDefaultSubnet;

/// Default broadcasting timeout for the AsyncBroadcaster
extern const NSTimeInterval AsyncNetworkBroadcastDefaultTimeout;

/// Default timeout for the AsyncRequest
extern const NSTimeInterval AsyncRequestDefaultTimeout;


#pragma mark - Public Functions

/// Return the Dispatch Queue used by AsyncNetwork
extern dispatch_queue_t AsyncNetworkDispatchQueue();

/// Set the Dispatch Queue used by AsyncNetwork
extern void SetAsyncNetworkDispatchQueue(dispatch_queue_t queue);

/// Return the IP addresses of all local interfaces.
extern NSArray *AsyncNetworkGetLocalIPAddresses(void);

/// Test if a given IP address string is local
extern BOOL AsyncNetworkIPAddressIsLocal(NSString *address);
