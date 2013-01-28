//
//  MSCurrencyFormatter.m
//  MA Mobile
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 POS Management. All rights reserved.
//

#import "MSCurrencyFormatter.h"

@interface MSCurrencyFormatter ()

@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, weak) UITextField *assignedTextField;
@property (nonatomic, assign) BOOL withToggleButton;
@property (nonatomic, assign) BOOL newButton;
@property (nonatomic, assign) BOOL keyboardDidShow;

@end

@implementation MSCurrencyFormatter

- (id)initWithLocale:(NSLocale *)locale withToggleButton:(BOOL)toggleButton
{
  if (self = [super init]) {
    [self setLocale:locale];
    [self setWithToggleButton:toggleButton];
    [self setFormatter:[[NSNumberFormatter alloc] init]];
    [[self formatter] setNumberStyle:NSNumberFormatterCurrencyStyle];
    [[self formatter] setLocale:[self locale]];

    if ([self withToggleButton] && [[self toggleButton] isEqual:nil]) {
      [self setToggleButton:[UIButton buttonWithType:UIButtonTypeCustom]];

      [[self toggleButton] setFrame:CGRectMake(0, 163, 105, 53)];
      [[self toggleButton] setAdjustsImageWhenHighlighted:NO];
      [[self toggleButton] setImage:[UIImage imageNamed:@"toggleButtonUp.png"] forState:UIControlStateNormal];
      [[self toggleButton] setImage:[UIImage imageNamed:@"toggleButtonDown.png"] forState:UIControlStateHighlighted];
      [[self toggleButton] addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setNewButton:TRUE];
  }

  return self;
}

- (id)initWithLocale:(NSLocale *)locale
{
  return [self initWithLocale:locale withToggleButton:NO];
}

- (id)init
{
  return [self initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
}

#pragma mark UIKeyboard Notifications

- (void)dealloc
{
  [self endWatchingForKeyboard];
}

- (void)startWatchingForKeyboardFromTextField:(UITextField *)textField
{
  self.assignedTextField = textField;
  self.assignedTextField.keyboardType = UIKeyboardTypeNumberPad;

  if (![[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
    if ([self withToggleButton]) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardStartedEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasDismissed:) name:UIKeyboardWillHideNotification object:nil];
  }
}

- (void)keyboardDidShow:(NSNotification *)note
{
  self.keyboardDidShow = TRUE;
  if ([self.assignedTextField isFirstResponder] && self.newButton) [self addButtonToKeyboard];
}

- (void)keyboardStartedEditing:(NSNotification *)note
{
  if ([[self assignedTextField] isFirstResponder]) {
    if ([self withToggleButton] && [self newButton] && [self keyboardDidShow]) [self addButtonToKeyboard];
    if ([[[self assignedTextField] text] length] == 0 && [[[self assignedTextField] delegate] isEqual:self]) {
      [[self assignedTextField] setText:[[self formatter] stringFromNumber:[NSNumber numberWithFloat:0.0]]];
    }
    [[self toggleButton] setHidden:NO];
    [[self toggleButton] setUserInteractionEnabled:YES];
  } else {
    [[self toggleButton] setHidden:YES];
    [[self toggleButton] setUserInteractionEnabled:NO];
  }
}

- (void)keyboardWasDismissed:(NSNotification *)note
{
  if ([self doesAlertViewExist]) [self endWatchingForKeyboard];

  [self setNewButton:TRUE];
  if ([self withToggleButton]) [self setKeyboardDidShow:FALSE];
}

- (void)endWatchingForKeyboard
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Private Methods

- (void)addButtonToKeyboard
{
  NSInteger viewIndex = ([self doesAlertViewExist]) ? 2 : 1;
  UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:viewIndex];

  for (UIView *keyboard in [tempWindow subviews]) {
    if ([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES) {
      [keyboard addSubview:[self toggleButton]];
      self.newButton = FALSE;
    }
  }
}

- (void)toggleButton:(id)sender
{
  if ([[[self assignedTextField] text] length] > 0) {
    [[[self assignedTextField] delegate] textField:[self assignedTextField] shouldChangeCharactersInRange:NSMakeRange(0, 1) replacementString:@"-"];
  }
}

- (BOOL)doesAlertViewExist
{
  for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
    for (UIView* view in [window subviews]) {
      if ([view isKindOfClass:[UIAlertView class]] || [view isKindOfClass:[UIActionSheet class]]) return YES;
    }
  }
  return NO;
}

#pragma mark UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  [textField setText:[self formatTextField:textField withCharactersInRange:range withReplacementString:string]];
  return NO;
}

- (NSString *)formatTextField:(UITextField *)textField withCharactersInRange:(NSRange)range withReplacementString:(NSString *)string
{
  NSString *minus = @"-";

  if ([string hasSuffix:minus]) {
    if ([[[textField text] substringToIndex:1] isEqualToString:minus]) {
      return textField.text = [[textField text] substringFromIndex:1];
    }
    return textField.text = [minus stringByAppendingString:[textField text]];
  }
  if (range.location == 0 && range.length == 1 && [string isEqualToString:@""]) {
    return [[textField text] substringFromIndex:1];
  }

  NSInteger currencyScale = -1 * [[self formatter] maximumFractionDigits];
  NSMutableString *filteredString = [NSMutableString stringWithCapacity:[[textField text] length]];
  NSScanner *scanner = [NSScanner scannerWithString:[textField text]];
  NSCharacterSet *allowedChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

  while ([scanner isAtEnd] == NO) {
    NSString *buffer;
    if ([scanner scanCharactersFromSet:allowedChars intoString:&buffer]) {
      [filteredString appendString:buffer];
    } else {
      [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
  }

  NSString *enteredDigits = filteredString;
  BOOL isNegative = [[[textField text] substringToIndex:1] isEqualToString:minus];

  NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
  for (int i = 0; i < [string length]; i++) {
    if (![myCharSet characterIsMember:[string characterAtIndex:i]]) return [textField text];
  }

  if ([string length]) {
    if ([enteredDigits length] > 10) {
      return [textField text];
    } else {
      enteredDigits = [enteredDigits stringByAppendingFormat:@"%d", [string integerValue]];
    }
  } else {
    NSUInteger len = [enteredDigits length];
    if (len > 1) {
      enteredDigits = [enteredDigits substringWithRange:NSMakeRange(0, len - 1)];
    } else {
      enteredDigits = @"";
    }
  }

  NSDecimalNumber *decimal = nil;
    
  if (![enteredDigits isEqualToString:@""]) {
    decimal = [[NSDecimalNumber decimalNumberWithString:enteredDigits] decimalNumberByMultiplyingByPowerOf10:currencyScale];
  } else {
    decimal = [NSDecimalNumber zero];
  }

  NSString *results = @"";
    
  if (isNegative) {
    results = [NSString stringWithFormat:@"-%@",[[self formatter] stringFromNumber:decimal]];
  } else {
    results = [[self formatter] stringFromNumber:decimal];
  }
  return results;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  if ((void (^)(void))self.textFieldShouldBeginEditingBlock) {
    self.textFieldShouldBeginEditingBlock(textField);
  }
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  if ((void (^)(void))self.textFieldDidBeginEditingBlock) {
    self.textFieldDidBeginEditingBlock(textField);
  }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  if ((void (^)(void))self.textFieldShouldEndEditingBlock) {
    self.textFieldShouldEndEditingBlock(textField);
  }
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  if ((void (^)(void))self.textFieldDidEndEditingBlock) {
    self.textFieldDidEndEditingBlock(textField);
  }
}

#pragma mark Class Methods

+ (NSDecimalNumber *)decimalNumberFromFormattedString:(NSString *)string
{
  NSMutableString *strippedString = [NSMutableString stringWithCapacity:[string length]];
  NSScanner *scanner = [NSScanner scannerWithString:string];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-"];

  while ([scanner isAtEnd] == NO) {
    NSString *buffer;
    if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
      [strippedString appendString:buffer];
    } else {
      [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
  }

  return [NSDecimalNumber decimalNumberWithString:strippedString];
}

@end