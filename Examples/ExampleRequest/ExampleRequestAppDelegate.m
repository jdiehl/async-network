//
//  ExampleRequestAppDelegate.m
//  ExampleRequest
//
//  Created by Jonathan Diehl on 12.08.11.
//

#import "ExampleRequestAppDelegate.h"

#import "PingServer.h"
#import "RequestController.h"

@implementation ExampleRequestAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// create a ping server
	pingServer = [PingServer new];
	
	// create a request window controller
	controller = [[RequestController alloc] initWithWindowNibName:@"RequestController"];
	[controller showWindow:self];
}

@end
