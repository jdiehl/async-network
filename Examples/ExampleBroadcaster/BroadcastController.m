//
//  BroadcastController.m
//  AsyncNetwork
//
//  Created by Jonathan Diehl on 23.05.11.
//

#import "BroadcastController.h"

// the broadcasting port
#define kBroadcastPort 50000

@implementation BroadcastController

@synthesize output, input;


// initiailize
- (void)awakeFromNib;
{
	// Create the broadcaster
	broadcaster = [AsyncBroadcaster new];
	
	// assign this controller as its delegate
	broadcaster.delegate = self;
	
	// specify the broadcasting port
	broadcaster.port = kBroadcastPort;
	
	// do not ignore local broadcasts so we can test this on a single machine
	// you should probably leave this enabled in most cases
	broadcaster.ignoreLocalBroadcasts = NO;
	
	// start the broadcaster
	[broadcaster start];
}

// Send the text from the input field as a broadcast
- (IBAction)sendBroadcast:(id)sender;
{
	// get the message from the text field
	NSString *message = input.stringValue;
	
	// store the message in a data object
	NSData *encodedMessage = [message dataUsingEncoding:NSUTF8StringEncoding];
	
	// broadcast the encoded message
	[broadcaster broadcast:encodedMessage];
	
	// clear the input text field
	input.stringValue = @"";
}


#pragma mark - AsyncBroadcasterDelegate

/**
 @brief The broadcaster received some data from a host.
 @param theBroadcaster The broadcaster that received data
 @param data The data
 @param host The IP address string of the host that the data was received from
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
{
	// decode the message from the data object
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// format the message with information about the host and port
	NSString *formattedMessage = [NSString stringWithFormat:@"[%@:%d] %@\n", host, theBroadcaster.port, message];
	
	// display the message
	[output insertText:formattedMessage];
	
	// clean up
	[message release];
}

/**
 @brief The AsyncConnection encountered an error.
 
 Errors can occur in the following situations:
 - In -[AsyncConnection start] if the initialization of the broadcast socket fails
 - In -[AsyncConnection start] if the initialization of the listening socket fails
 - If the AsyncUdpSocket reports an error
 
 @param theBroadcaster The broadcaster that encountered the error
 @param error An object describing the error
 */
- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;
{
	// just inform the user
	[NSApp presentError:error];
}


#pragma mark memory management

// clean up
- (void)dealloc
{
	[broadcaster release];
    [super dealloc];
}

@end
