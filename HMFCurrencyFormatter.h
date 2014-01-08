//
//  HMFCurrencyFormatter.h
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 Brandon Butler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMFCurrencyFormatter : NSObject <UITextFieldDelegate>

-(void)startWatchingForKeyboardFromTextField:(UITextField *)textField;

+(NSString *)formatTextField:(UITextField *)textField withCharactersInRange:(NSRange)range withReplacementString:(NSString *)string;

+(NSDecimalNumber *)decimalNumberFromFormattedString:(NSString *)string;

@end
