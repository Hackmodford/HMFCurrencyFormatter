//
//  MSCurrencyFormatter.h
//  MA Mobile
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 POS Management. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCurrencyFormatter : NSObject <UITextFieldDelegate>

@property (nonatomic, copy) void (^textFieldShouldBeginEditingBlock)();
@property (nonatomic, copy) void (^textFieldDidBeginEditingBlock)();
@property (nonatomic, copy) void (^textFieldShouldEndEditingBlock)();
@property (nonatomic, copy) void (^textFieldDidEndEditingBlock)();

- (id)initWithLocale:(NSLocale *)locale withToggleButton:(BOOL)toggleButton;
- (id)initWithLocale:(NSLocale *)locale;
- (void)startWatchingForKeyboardFromTextField:(UITextField *)textField;
- (NSString *)formatTextField:(UITextField *)textField withCharactersInRange:(NSRange)range withReplacementString:(NSString *)string;

+ (NSDecimalNumber *)decimalNumberFromFormattedString:(NSString *)string;

@end
