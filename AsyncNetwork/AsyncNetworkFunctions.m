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