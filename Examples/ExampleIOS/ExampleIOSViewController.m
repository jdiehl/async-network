//
//  ExampleIOSViewController.m
//  ExampleIOS
//
//  Created by Jonathan Diehl on 24.05.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#import "ExampleIOSViewController.h"

// the service type for new servers and clients
#define kDefaultServiceType @"_ExampleMac._tcp"

@implementation ExampleIOSViewController

@synthesize output;


#pragma mark UIViewController

// Initialize
- (void)viewDidLoad;
{
	// create the client
	client = [AsyncClient new];
	
	// configure the service type to match that of ExampleMac
	client.serviceType = kDefaultServiceType;
	
	// make us the delegate
	client.delegate = self;
	
	// start the client
	[client start];
}

// clean up
- (void)dealloc;
{
	// tear down the client
	[client release];
    [super dealloc];
}


#pragma mark AsyncClientDelegate

/**
 @brief The client did receive an object from a server
 @param theClient The client that received the object
 @param object The object
 @param tag The transaction tag for the object
 @param connection The connection to the server
 */
- (void)client:(AsyncClient *)theClient didReceiveObject:(id)object tag:(UInt32)tag fromConnection:(AsyncConnection *)connection;
{
	// display log entry
	output.text = [output.text stringByAppendingFormat:@"%@\n", object];
}

/**
 @brief The AsyncConnection encountered an error.
 
 Errors are forwarded from all connection objects.
 @see AsyncConnectionDelegate
 @param theClient The client that encountered the error
 @param error An object describing the error
 */
- (void)client:(AsyncClient *)theClient didFailWithError:(NSError *)error;
{
	// log the error
	NSLog(@"error: %@", error);
}

@end
