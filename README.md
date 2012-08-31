MSCurrencyFormatter
===================

A piece of code that will automatically format a uitextfield with a numberpad to behave like an ATM

Here's an example

1. Create a property for the formatter

@property (nonatomic, retain) MSCurrencyFormatter *priceFormatter;

2. In the viewDidLoad make sure to initalize

self.priceFormatter = [[MSCurrencyFormatter alloc] init];

3. Wherever you setup your textfield set the priceFormatter as the delegate

myTextField.delegate = self.priceFormatter;

4. To automatically add the "+/-" button to the numberpad (iphone only) call this method.

[self.priceFormatter startWatchingForKeyboardFromTextField:myTextField];

5. (optional) if you want to handle the delegation yourself you can do this also.

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  
  textField.text = [MSCurrencyFormatter formatTextField:textField withReplacementString:string]
  return NO;

6. You're done!
