//
//  MSCurrencyFormatter.h
//  MA Mobile
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 POS Management. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCurrencyFormatter : NSObject <UITextFieldDelegate> 

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, weak) UITextField *assignedTextField;

-(void)startWatchingForKeyboardFromTextField:(UITextField *)textField;

-(void)endWatchingForKeyboard;

+(NSString *)formatTextField:(UITextField *)textField withReplacementString:(NSString *)string;

@end
