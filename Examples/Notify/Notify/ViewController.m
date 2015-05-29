//
//  ViewController.m
//  Notify
//
//  Created by Jonathan Diehl on 16/03/15.
//  Copyright (c) 2015 Jonathan Diehl. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.broadcaster = [AsyncBroadcaster new];
	self.broadcaster.delegate = self;
	self.broadcaster.port = 50001;
	self.broadcaster.ignoreSelf = NO;
	[self.broadcaster start];

	self.view.backgroundColor = [UIColor blackColor];
}

- (void)ping;
{
	self.view.backgroundColor = [UIColor whiteColor];
	
	[UIView animateWithDuration:0.2 animations:^{
		self. view.layer.backgroundColor = [UIColor blackColor].CGColor;
	}];
}

#pragma mark - AsyncBroadcasterDelegate

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didReceiveData:(NSData *)data fromHost:(NSString *)host;
{
	[self ping];
}

- (void)broadcaster:(AsyncBroadcaster *)theBroadcaster didFailWithError:(NSError *)error;
{
	NSLog(@"%@", error);
}

@end
