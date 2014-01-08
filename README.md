HMFCurrencyFormatter
===================

A piece of code that will automatically format a uitextfield with a numberpad to behave like an ATM

Here's an example

>Create a property for the formatter
>
>```objective-c
>@property (nonatomic, retain) HMFCurrencyFormatter *priceFormatter;
>```
>In the viewDidLoad make sure to initalize
>
>```objective-c
>self.priceFormatter = [[HMFCurrencyFormatter alloc] init];
>```
>
>Wherever you setup your textfield set the priceFormatter as the delegate
>
>```objective-c
>myTextField.delegate = self.priceFormatter;
>```
>
>To automatically add the "+/-" button to the numberpad (iphone only) call this method.
>
>```objective-c
>[self.priceFormatter startWatchingForKeyboardFromTextField:myTextField];
>```
>
>(optional) if you want to handle the delegation yourself you can do this also.
>
>```objective-c
>- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
>  
>  textField.text = [HMFCurrencyFormatter formatTextField:textField withReplacementString:string]
>  return NO;
>}
>```
>
>If you have a textfield in a UIAlertView be sure to call "startWatchingFor..." everytime you show the alert.
>
>You're done!
