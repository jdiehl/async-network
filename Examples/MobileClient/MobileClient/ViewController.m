//
//  ViewController.m
//  MobileClient
//
//  Created by Jonathan Diehl on 3/20/12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)appendLogMessage:(NSString *)text;
@end

@implementation ViewController

@synthesize client = _client;
@synthesize output = _output;
@synthesize input = _input;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// create and configure the client
	self.client = [AsyncClient new];
	self.client.serviceType = kDefaultServiceType;
	self.client.delegate = self;
	
	// start the client
	[self.client start];
	
	[self.input becomeFirstResponder];
}

- (void)dealloc;
{
	[self.client stop];
	self.client.delegate = nil;
}

#pragma mark - UITextFieldDelegate

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	// ask the client to send the input string to all connected servers
    [self.client sendObject:self.input.text];
	
	// display log entry
	NSString *string = [NSString stringWithFormat:@">> %@\n", self.input.text];
	[self appendLogMessage:string];
	
	// clear input
	self.input.text = @"";
	
	return NO;
}

#pragma mark - AsyncClientDelegate

- (void)client:(AsyncClient *)theClient didConnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ connected]\n", connection.netService.name];
	[self appendLogMessage:string];
}

- (void)client:(AsyncClient *)theClient didDisconnect:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"[%@ disconnected]\n", connection.netService.name];
	[self appendLogMessage:string];
}

- (void)client:(AsyncClient *)theClient didReceiveCommand:(AsyncCommand)command object:(id)object fromConnection:(AsyncConnection *)connection;
{
	// display log entry
    NSString *string = [NSString stringWithFormat:@"<< [%@] %@\n", connection.netService.name, object];
	[self.output insertText:string];
}

- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;
{
	[self.output insertText:[NSString stringWithFormat:@"[error] %@\n", error.localizedDescription]];
}


#pragma mark - private methods

- (void)appendLogMessage:(NSString *)text;
{
    self.output.text = [self.output.text stringByAppendingString:text];
	
	// scroll to bottom
	if (self.output.contentSize.height > self.output.bounds.size.height) {
		[self.output setContentOffset:CGPointMake(0, self.output.contentSize.height - self.output.bounds.size.height) animated:YES];
	}
}


@end
