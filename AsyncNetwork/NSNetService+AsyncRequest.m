//
//  NSNetService+AsyncRequest.m
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 20.10.12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import "NSNetService+AsyncRequest.h"

@implementation NSNetService (AsyncRequest)

- (void)requestCommand:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)response;
{
	[AsyncRequest fireRequestWithNetService:self command:command object:object responseBlock:response];
}

@end
