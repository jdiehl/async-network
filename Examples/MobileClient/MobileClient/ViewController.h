//
//  ViewController.h
//  MobileClient
//
//  Created by Jonathan Diehl on 3/20/12.
//  Copyright (c) 2012 RWTH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncNetwork.h"

@interface ViewController : UIViewController <UITextFieldDelegate, AsyncClientDelegate>

@property (retain) AsyncClient *client;

@property (retain, nonatomic) IBOutlet UITextView *output;
@property (retain, nonatomic) IBOutlet UITextField *input;

@end
