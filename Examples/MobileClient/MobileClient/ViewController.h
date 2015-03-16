//
//  ViewController.h
//  MobileClient
//
//  Created by Jonathan Diehl on 16/03/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncNetworkIOS/AsyncNetwork.h>

@interface ViewController : UIViewController <AsyncClientDelegate>

@property (retain) AsyncClient *client;

@property (weak, nonatomic) IBOutlet UITextView *output;
@property (weak, nonatomic) IBOutlet UITextField *input;

@end

