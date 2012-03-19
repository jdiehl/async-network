//
//  AsyncNetworkFunctions.m
//  ExampleBroadcaster
//
//  Created by Jonathan Diehl on 21.07.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

#import "AsyncNetworkFunctions.h"

// return the local ip addresses
NSArray *AsyncNetworkGetLocalIPAddresses(void)
{
	// retrieve the current interfaces - returns 0 on success
	struct ifaddrs *interfaces;
	int success = getifaddrs(&interfaces);
	if(success != 0) {
		NSLog(@"Could not get interfaces");
		return nil;
	}
	
	// Loop through linked list of interfaces
	NSMutableArray *addresses = [NSMutableArray arrayWithCapacity:2];
	NSString *address;
	struct ifaddrs *temp_addr = interfaces;
	while(temp_addr != NULL) {
		
		if(temp_addr->ifa_addr->sa_family == AF_INET)
		{
			// Check if interface is en*
			if(temp_addr->ifa_name[0] == 'e' && temp_addr->ifa_name[1] == 'n') {
				
				// Get NSString from C String
				address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				[addresses addObject:address];
			}
		}
		temp_addr = temp_addr->ifa_next;
	}
	
	// clean up
	freeifaddrs(interfaces); 
	
	return [NSArray arrayWithArray:addresses];
}

// determine whether an address is local
BOOL AsyncNetworkIPAddressIsLocal(NSString *address)
{
	static NSArray *localIPAddresses = nil;
	if(!localIPAddresses) {
		localIPAddresses = [AsyncNetworkGetLocalIPAddresses() retain];
	}
	return [localIPAddresses containsObject:address];
}