/**
 * Copyright (C) 2011 Jonathan Diehl
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 * https://github.com/jdiehl/async-network
 */

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
