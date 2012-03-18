//
//  PingServer.h
//  ExampleLoader
//
//  Created by Jonathan Diehl on 25.05.11.
//

#import <Foundation/Foundation.h>
#import <AsyncNetwork/AsyncNetwork.h>

/**
 The Ping Server will immediately send any string received back to the sender
 */
@interface PingServer : NSObject <AsyncServerDelegate> {
	
@private
	AsyncServer *server;
}

@end
