//
//  ViewController.h
//  Notify
//
//  Created by Jonathan Diehl on 16/03/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncNetwork/AsyncNetwork.h>

@interface ViewController : UIViewController <AsyncBroadcasterDelegate>

@property (strong) AsyncBroadcaster *broadcaster;

@end

