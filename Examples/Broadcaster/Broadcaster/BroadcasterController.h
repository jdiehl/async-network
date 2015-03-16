//
//  BroadcasterController.h
//  Broadcaster
//
//  Created by Jonathan Diehl on 15/03/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface BroadcasterController : NSObject <AsyncBroadcasterDelegate>

@property (weak) IBOutlet NSTextField *input;
@property (weak) IBOutlet NSTextField *output;

@property (strong) AsyncBroadcaster *broadcaster;
- (IBAction)broadcast:(id)sender;

@end
