//
//  ViewController.h
//  DAPPER
//
//  Created by xu jason on 14-3-22.
//  Copyright (c) 2014年 Vbenz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UartLib.h"

@interface ViewController : UIViewController <UartDelegate>

@property (readonly, nonatomic) IBOutlet UITextView *recvDataView;

@property (weak, nonatomic) IBOutlet UILabel *peripheralName;

@property (weak, nonatomic) IBOutlet UITextField *sendDataView;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;

- (IBAction)scanStart:(id)sender;

- (IBAction)scanStop:(id)sender;

- (IBAction)connect:(id)sender;

- (IBAction)Disconnect:(id)sender;

- (IBAction)sendData:(id)sender;

- (IBAction)printQR:(id)sender;

- (IBAction)printQR_1:(id)sender;

- (IBAction)printQR_2:(id)sender;

- (IBAction)printBarCode:(id)sender;

- (IBAction)printPng:(id)sender;
@end
