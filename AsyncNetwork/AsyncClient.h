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
#import "AsyncClientDelegate.h"
#import "AsyncConnectionDelegate.h"

/**
 @brief A client can discover and automatically connect to all servers on the network via Bonjour.
 @details 
 @author Jonathan Diehl
 @date 08.03.11
 */
@interface AsyncClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, AsyncConnectionDelegate> {
	
@private
	BOOL autoConnect;
	NSMutableSet *connections;
	
	// net service browser for automatic service discovery via Bonjour
	NSNetServiceBrowser *netServiceBrowser;
	
	// netservice configuration
	NSString *serviceType; // the net service type
	NSString *serviceDomain; // the domain where bonjour will be published, default: .local
	
	// delegate
	id<AsyncClientDelegate> delegate;
}

/// The net service type identifier (default: _AsyncNetwork._tcp).
@property(nonatomic, retain) NSString *serviceType;

/// The net service domain (default: local.).
@property(nonatomic, retain) NSString *serviceDomain;

/// Configuer whether the client automatically connect to a discovered server (default: YES).
@property(assign) BOOL autoConnect;

/// The delegate.
@property(assign) id<AsyncClientDelegate> delegate;

/// All active server connections.
@property(readonly) NSSet *connections;

/**
 @brief Start the client.
 
 Sets up the Bonjour net service browser.
 */
- (void)start;

/**
 @brief Stop the client.
 
 Closes all active connections and stops the Bonjour net service browser.
 */
- (void)stop;

/**
 @brief Send an object to all connected servers.
 
 To send objects to individual servers use the connections property.
 @see connections
 @param object The object to be sent.
 @param tag The transaction tag.
 */
- (void)sendObject:(id<NSCoding>)object tag:(UInt32)tag;

@end
