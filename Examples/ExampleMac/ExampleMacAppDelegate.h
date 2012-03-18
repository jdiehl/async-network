//
//  ExampleMacAppDelegate.h
//  ExampleMac
//
//  Created by Jonathan Diehl on 23.05.11.
//

#import <Cocoa/Cocoa.h>

@interface ExampleMacAppDelegate : NSObject <NSApplicationDelegate>

/// Create a new server
- (IBAction)addServer:(id)sender;

/// Create a new client
- (IBAction)addClient:(id)sender;

@end
