//
//  NSNetService+AsyncRequest.h
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 20.10.12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncRequest.h"

@interface NSNetService (AsyncRequest)

- (void)requestCommand:(AsyncCommand)command object:(NSObject<NSCoding> *)object responseBlock:(AsyncNetworkRequestBlock)response;

@end
