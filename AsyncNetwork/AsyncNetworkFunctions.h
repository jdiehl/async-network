//
//  AsyncNetworkFunctions.h
//  ExampleBroadcaster
//
//  Created by Jonathan Diehl on 21.07.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Return the IP addresses of all local interfaces.
 @return Array of all local IP address strings
 */
NSArray *AsyncNetworkGetLocalIPAddresses(void);

/**
 @brief Test if a given IP address string is local
 @param address The IP address string to be tested
 @return YES if the IP address string is local
 */
BOOL AsyncNetworkIPAddressIsLocal(NSString *address);
