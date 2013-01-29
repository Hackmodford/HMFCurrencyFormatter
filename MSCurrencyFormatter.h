//
//  MSCurrencyFormatter.h
//  MA Mobile
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 POS Management. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCurrencyFormatter : NSObject <UITextFieldDelegate>

@property (nonatomic, copy) void (^textFieldShouldBeginEditingBlock)(UITextField *textField);
@property (nonatomic, copy) void (^textFieldDidBeginEditingBlock)(UITextField *textField);
@property (nonatomic, copy) void (^textFieldShouldEndEditingBlock)(UITextField *textField);
@property (nonatomic, copy) void (^textFieldDidEndEditingBlock)(UITextField *textField);

- (id)initWithLocale:(NSLocale *)locale withExtraButton:(int)extraButton;
- (id)initWithLocale:(NSLocale *)locale withDoubleZerosButton:(BOOL)doubleZerosButton;
- (id)initWithLocale:(NSLocale *)locale withToggleButton:(BOOL)toggleButton;
- (id)initWithLocale:(NSLocale *)locale;
- (void)startWatchingForKeyboardFromTextField:(UITextField *)textField;
- (NSString *)formatTextField:(UITextField *)textField withCharactersInRange:(NSRange)range withReplacementString:(NSString *)string;

+ (NSDecimalNumber *)decimalNumberFromFormattedString:(NSString *)string;

@end
