//
//  MSCurrencyFormatter.m
//  MA Mobile
//
//  Created by Brandon Butler on 8/30/12.
//  Copyright (c) 2012 POS Management. All rights reserved.
//

#import "MSCurrencyFormatter.h"

@interface MSCurrencyFormatter ()

@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, weak) UITextField *assignedTextField;
@property (nonatomic, assign) BOOL newButton;
@property (nonatomic, assign) BOOL keyboardDidShow;

@end

@implementation MSCurrencyFormatter

- (id)init {
    
    if ((self = [super init])) {
        
        if (self.toggleButton == nil) {
            
            // create custom button
            self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.toggleButton.frame = CGRectMake(0, 163, 105, 53);
            self.toggleButton.adjustsImageWhenHighlighted = NO;
            [self.toggleButton setImage:[UIImage imageNamed:@"toggleButtonUp.png"] forState:UIControlStateNormal];
            [self.toggleButton setImage:[UIImage imageNamed:@"toggleButtonDown.png"] forState:UIControlStateHighlighted];
            [self.toggleButton addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        self.newButton = TRUE;
    }
    
    return self;
}

#pragma mark UIKeyboard Notifications

-(void)dealloc {
    
    [self endWatchingForKeyboard];
}

-(void)startWatchingForKeyboardFromTextField:(UITextField *)textField {
    
    self.assignedTextField = textField;
    
    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        
        NSLog(@"start watching for keyboard");
        

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardStartedEditing:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasDismissed:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        
        
    }
}



- (void)keyboardDidShow:(NSNotification *)note {
    
    self.keyboardDidShow = TRUE;

    if ([self.assignedTextField isFirstResponder] && self.newButton) {
        
        NSLog(@"A new button is needed.");
        
        [self addButtonToKeyboard];
        
    }
    
}


- (void)keyboardStartedEditing:(NSNotification *)note {
    
    //This removes the button if we go to a different textfield.
    
    if ([self.assignedTextField isFirstResponder]) {
        
        //this will catch if a keyboard was already present and we changed first responder to our keyboard and need to add the button.
        if (self.newButton && self.keyboardDidShow) {
          NSLog(@"keyboard started editing and newButton is needed and the keyboard is already visible");
            [self addButtonToKeyboard];
        }
        
        //textfield must have something in it otherwise this will crash.
        if ([self.assignedTextField.text length] == 0 && self.assignedTextField.delegate == self) {
            self.assignedTextField.text = @"$0.00";
        }

        self.toggleButton.hidden = NO;
        self.toggleButton.userInteractionEnabled = YES;
        
    } else {
        
        self.toggleButton.hidden = YES;
        self.toggleButton.userInteractionEnabled = NO;
        
    }
 
}

- (void)keyboardWasDismissed:(NSNotification *)note {
    
    
    if ([self doesAlertViewExist]) {
        //alertViewExists therefore uitextfield will soon be released stop watching for events now to fix memory management bugs.
        [self endWatchingForKeyboard];
    }
    
    self.newButton = TRUE;
    self.keyboardDidShow = FALSE;
    NSLog(@"Button is gone");
    
}

-(void)endWatchingForKeyboard {
    
    NSLog(@"end watching for keyboard");
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark Private Methods

-(void)addButtonToKeyboard {
    
    NSLog(@"add Button");

    //If a alertview is present with a textfield the viewIndex will be different than 1
    NSInteger viewIndex = 1;
    
    if ([self doesAlertViewExist]) {
        viewIndex = 2;
    }
    
    // locate keyboard view
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:viewIndex];
    UIView* keyboard;
    for(int i=0; i < [tempWindow.subviews count]; i++) {
        
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard view found; add the custom button to it
        if([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES) {
                        
            [keyboard addSubview:self.toggleButton];
            
            self.newButton = FALSE;
            
        }
    }
    
}

-(void)toggleButton:(id)sender {
    
    if ([self.assignedTextField.text length] > 0) {
        
        if ([[self.assignedTextField.text substringToIndex:1] isEqualToString:@"-"]) {
            
            self.assignedTextField.text = [self.assignedTextField.text substringFromIndex:1];
            
        } else {
            
            NSString *newString = @"-";
            self.assignedTextField.text = [newString stringByAppendingString:self.assignedTextField.text];
        }
    }
}

- (BOOL) doesAlertViewExist {
    
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        for (UIView* view in window.subviews) {
            BOOL alert = [view isKindOfClass:[UIAlertView class]];
            BOOL action = [view isKindOfClass:[UIActionSheet class]];
            if (alert || action)
                return YES;
        }
    }
    return NO;
}

#pragma mark UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.text = [MSCurrencyFormatter formatTextField:textField withReplacementString:string];
    return NO;
    
}

#pragma mark Class Methods

+(NSString *)formatTextField:(UITextField *)textField withReplacementString:(NSString *)string {
    
    //this is specifically for ipads though in theory it would work for iphones
    //If user types a - just flip/flop to a negative or positive number.
    if ([string hasSuffix:@"-"]) {
        if ([[textField.text substringToIndex:1] isEqualToString:@"-"]) {
            
            return textField.text = [textField.text substringFromIndex:1];
            
        }
            
            NSString *newString = @"-";
            return textField.text = [newString stringByAppendingString:textField.text];
        
    }
    
    NSInteger currencyScale;

    //setup formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    currencyScale = -1 * [formatter maximumFractionDigits];
    
    //First analyze string for numbers only.
    NSMutableString *filteredString = [NSMutableString stringWithCapacity:textField.text.length];
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
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
    
    
    // Next Check if it is negative and remember that.
    BOOL isNegative = FALSE;
    
    if ([[textField.text substringToIndex:1] isEqualToString:@"-"]) {
        
        isNegative = TRUE;
        
    }
    
    
    //only allow numbers to be entered via keypad/keyboard
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            
            return textField.text;
        }
    }
    
    // Check the length of the string
    if ([string length]) {
        if ([enteredDigits length] > 10) {
            //This makes sure that we don't have a long price.

            return textField.text;
        } else {
            
            enteredDigits = [enteredDigits stringByAppendingFormat:@"%d", [string integerValue]];
            
        }
    } else {
        
        // This is a backspace
        NSUInteger len = [enteredDigits length];
        if (len > 1) {
            
            enteredDigits = [enteredDigits substringWithRange:NSMakeRange(0, len - 1)];
        } else {
            
            enteredDigits = @"";
        }
    }
    
    NSDecimalNumber *decimal = nil;
    
    if ( ![enteredDigits isEqualToString:@""]) {
        decimal = [[NSDecimalNumber decimalNumberWithString:enteredDigits] decimalNumberByMultiplyingByPowerOf10:currencyScale];
    } else {
        decimal = [NSDecimalNumber zero];
    }
    
    // Replace the text with the localized decimal number
    
    NSString *results = @"";
    
    if (isNegative) {
        results = [NSString stringWithFormat:@"-%@",[formatter stringFromNumber:decimal]];
    } else {
        results = [formatter stringFromNumber:decimal];
    }
    
    return results;
    
}

@end
