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

@class AsyncClient;

/// AsyncClient delegate protocol
@protocol AsyncClientDelegate <NSObject>
@optional

#pragma mark - AsyncClientDelegate
- (BOOL)client:(AsyncClient *)theClient didFindService:(NSNetService *)service moreComing:(BOOL)moreComing;
- (void)client:(AsyncClient *)theClient didRemoveService:(NSNetService *)service;
- (void)client:(AsyncClient *)theClient didConnect:(AsyncConnection *)connection;
- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;
- (void)client:(AsyncClient *)theClient didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection;
- (void)client:(AsyncClient *)theClient didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection responseBlock:(AsyncNetworkResponseBlock)block;
- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;

@end

/// A client can discover and automatically connect to all servers on the network via Bonjour.
@interface AsyncClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, AsyncConnectionDelegate>

@property (readonly) NSNetServiceBrowser *serviceBrowser;
@property (readonly) NSMutableSet *services;    // the discovered services, observable, do not change!
@property (readonly) NSMutableSet *connections; // the discovered connections, observable, do not change!

@property (unsafe_unretained) id<AsyncClientDelegate> delegate;
@property (strong) NSString *serviceType;   // Bonjour service type
@property (strong) NSString *serviceDomain; // Bonjour service domain
@property (assign) BOOL autoConnect;        // should the client automatically connect to discovered servers?
@property (assign) BOOL includesPeerToPeer; // should bluetooth peers be included?

- (void)start;
- (void)stop;

- (void)connectToService:(NSNetService *)service;

- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object responseBlock:(AsyncNetworkResponseBlock)block;
- (void)sendCommand:(AsyncCommand)command object:(id<NSCoding>)object;
- (void)sendObject:(id<NSCoding>)object;

@end
