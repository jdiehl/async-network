//
//  ExampleIOSViewController.h
//  ExampleIOS
//
//  Created by Jonathan Diehl on 24.05.11.
//  Copyright 2011 RWTH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AsyncNetwork/AsyncNetwork.h>
/**
 This is a minimalistic example for networking on iOS.
 
 Steps:
 1. Ensure that your device and your desktop are on the same wireless netowkr
 2. Run ExampleMac on your desktop
 3. Run ExampleIOS on your device
 
 The mobile device will connect to all servers created on the desktop and receive messages from them.
 Sending messages is not supported (although, it can be easily added).
 */
@interface ExampleIOSViewController : UIViewController <AsyncClientDelegate> {
	
@private
    AsyncClient *client;
	
	UITextView *output;
}

/// the output text field
@property(assign) IBOutlet UITextView *output;

@end
