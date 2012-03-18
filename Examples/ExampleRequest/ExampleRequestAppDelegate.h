//
//  ExampleRequestAppDelegate.h
//  ExampleRequest
//
//  Created by Jonathan Diehl on 12.08.11.
//

#import <Cocoa/Cocoa.h>

@class PingServer;
@class RequestController;
@interface ExampleRequestAppDelegate : NSObject <NSApplicationDelegate> {
	
@private
	PingServer *pingServer;
	RequestController *controller;
}

@end
