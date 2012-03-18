//
//  ServerController.h
//  ExampleMac
//
//  Created by Jonathan Diehl on 13.01.11.
//

#import <Foundation/Foundation.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface ServerController : NSWindowController <AsyncServerDelegate> {

@private
	AsyncServer *server;
	
	NSString *serviceName;
	NSString *serviceType;
	NSUInteger listenPort;
	NSTextView *output;
	NSTextField *input;
	NSTextField *status;
}

/// The Bonjour service name of the server
@property(retain) NSString *serviceName;

/// The Bonjour service type of the server
@property(retain) NSString *serviceType;

/// The listening port for the server
@property(assign) NSUInteger listenPort;

/// The output console
@property(assign) IBOutlet NSTextView *output;

/// The message input field
@property(assign) IBOutlet NSTextField *input;

/// The status text label
@property(assign) IBOutlet NSTextField *status;

/// Send the message from the input field to all connected servers
- (IBAction)sendInput:(id)sender;

@end
