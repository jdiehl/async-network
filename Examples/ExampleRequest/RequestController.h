//
//  RequestController.h
//  ExampleRequest
//
//  Created by Jonathan Diehl on 12.08.11.
//

#import <Cocoa/Cocoa.h>

@interface RequestController : NSWindowController {
	
@private
	NSTextView *output;
	NSTextField *input;
}

/// The input text field
@property(assign) IBOutlet NSTextView *output;

/// The output text field
@property(assign) IBOutlet NSTextField *input;

/// Send the message from the input text field as a request to the ping server
- (IBAction)send:(id)sender;

@end
