//
//  EchoServer.h
//  UnixDomain
//
//  Created by Jonathan Diehl on 07.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface EchoServer : NSObject <AsyncServerDelegate>

@property (readonly) AsyncServer *server;
@property (strong) NSURL *url;

- (void)start;
- (void)stop;

@end
