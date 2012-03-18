//
//  BroadcastController.h
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 23.05.11.
//

#import <Foundation/Foundation.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface BroadcastController : NSWindowController <AsyncBroadcasterDelegate> {
	
@private
	AsyncBroadcaster *broadcaster;
	
	NSTextView *output;
	NSTextField *input;
}

/// The output text field to log all messages to
@property(assign) IBOutlet NSTextView *output;

/// The input text field to get the message to be broadcastet from
@property(assign) IBOutlet NSTextField *input;

/// Send the text from the input field as a broadcast
- (IBAction)sendBroadcast:(id)sender;

@end
