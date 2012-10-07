//
//  AppDelegate.m
//  UnixDomain
//
//  Created by Jonathan Diehl on 07.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize inputField = _inputField;
@synthesize outputView = _outputView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_server = [EchoServer new];
	self.server.url = [NSURL fileURLWithPath:@"/tmp/echo.socket"];
	[self.server start];
}

- (IBAction)send:(id)selector;
{
	NSString *text = self.inputField.stringValue;
	[AsyncRequest fireRequestWithUrl:self.server.url command:0 object:text responseBlock:^(id<NSCoding> response, NSError *error) {
		NSString *responseText = [NSString stringWithFormat:@"%@\n", response];
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:responseText];
		[self.outputView.textStorage appendAttributedString:string];
	}];
}

@end
