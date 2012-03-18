//
//  RequestController.m
//  ExampleRequest
//
//  Created by Jonathan Diehl on 12.08.11.
//

#import "RequestController.h"
#import <AsyncNetwork/AsyncNetwork.h>

@implementation RequestController

@synthesize input, output;

// Send the message from the input text field as a request to the ping server
- (IBAction)send:(id)sender;
{
	// read the input message
	NSString *message = input.stringValue;
	
	// empty the input field
	input.stringValue = @"";
	
	// display log entry
	[output insertText:[NSString stringWithFormat:@">> %@\n", message]];
	
	// create a request to the ping server
	AsyncRequest *request = [AsyncRequest requestWithHost:AsyncNetworkLocalHost port:kPingServerPort];
	
	// add the message as the body of the request
	request.body = message;
	
	// fire the request
	[request fireWithCompletionBlock:^(id response, NSError *error) {
		
		// check for a reponse and display appropriate log entry
		if(response) {
			[output insertText:[NSString stringWithFormat:@"<< %@\n", response]];
		} else {
			[output insertText:[NSString stringWithFormat:@"Error: %@\n", error]];
		}
		
	}];
}


@end
