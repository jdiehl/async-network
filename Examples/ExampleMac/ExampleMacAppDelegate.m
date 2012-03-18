//
//  ExampleMacAppDelegate.m
//  ExampleMac
//
//  Created by Jonathan Diehl on 23.05.11.
//

// the offset for new windows
#define kArrangeOffset 20.0

// the port for new servers (automatic)
#define kDefaultListenPort 0

// the service type for new servers and clients
#define kDefaultServiceType @"_ExampleMac._tcp"

#import "ExampleMacAppDelegate.h"
#import "ClientController.h"
#import "ServerController.h"

@implementation ExampleMacAppDelegate

// Create a new server
- (IBAction)addServer:(id)sender;
{
	// the server id (increasing number)
	static NSUInteger serverId = 0;

	// create the server controller (it retains itself)
	ServerController *controller = [[ServerController alloc] initWithWindowNibName:@"ServerController"];
	
	// configure the service type
	controller.serviceType = kDefaultServiceType;

	// set the service name
	controller.serviceName = [NSString stringWithFormat:@"Server %d", ++serverId];
	
	// present the controller
	[controller showWindow:self];
	
	[controller release];
}

// Create a new client
- (IBAction)addClient:(id)sender;
{
	// create the server controller (retains itself)
	ClientController *controller = [[ClientController alloc] initWithWindowNibName:@"ClientController"];
	
	// configure the service type
	controller.serviceType = kDefaultServiceType;
	
	// present the controller
	[controller showWindow:self];

	[controller release];
}


#pragma mark NSApplicationDelegate

// started
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // create a server
	[self addServer:self];
	
	// create a client
	[self addClient:self];
}

@end
