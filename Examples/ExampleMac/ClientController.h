//
//  ClientController.h
//  ExampleMac
//
//  Created by Jonathan Diehl on 26.02.11.
//

#import <Cocoa/Cocoa.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface ClientController : NSWindowController <AsyncClientDelegate> {
	
@private
    AsyncClient *client;
	
	NSString *serviceType;
	NSTextView *output;
	NSTextField *input;
	NSTextField *status;
}

/// The Bonjour service type of the AsyncClient
@property(retain) NSString *serviceType;

/// The output console
@property(assign) IBOutlet NSTextView *output;

/// The message input field
@property(assign) IBOutlet NSTextField *input;

/// The status text label
@property(assign) IBOutlet NSTextField *status;

/// Send the message from the input field to all connected servers
- (IBAction)sendInput:(id)sender;

@end
