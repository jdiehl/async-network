//
//  EchoServer.m
//  UnixDomain
//
//  Created by Jonathan Diehl on 07.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "EchoServer.h"

@implementation EchoServer

@synthesize server = _server;
@synthesize url = _url;

- (void)start;
{
	NSAssert(self.url && self.url.path, @"Invalid URL: %@", self.url);
	if (!self.server) {
		_server = [AsyncServer new];
		self.server.delegate = self;
		self.server.url = self.url;
		[self.server start];
	}
}

- (void)stop;
{
	if (self.server) {
		self.server.delegate = nil;
		[self.server stop];
		_server = nil;
	}
}

- (void)dealloc
{
    [self stop];
}


#pragma mark - AsyncServerDelegate

- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection responseBlock:(AsyncNetworkResponseBlock)block;
{
	block(object);
}

@end
