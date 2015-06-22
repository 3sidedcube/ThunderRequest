#import "UIAlertController+TSCErrorRecoveryAttempter.h"
#import "TSCErrorRecoveryOption.h"
#import "TSCErrorRecoveryAttempter.h"

@implementation UIAlertController (TSCErrorRecoveryAttempter)

+ (void)presentError:(nonnull NSError *)error inViewController:(nonnull UIViewController *)viewController
{
    UIAlertController *alertController;
    if (!error.recoveryAttempter) {
        
        TSCErrorRecoveryAttempter *recoveryAttempter = [TSCErrorRecoveryAttempter new];
        alertController = [UIAlertController alertControllerWithError:[recoveryAttempter recoverableErrorWithError:error]];
        
    } else {
        
        alertController = [UIAlertController alertControllerWithError:error];
        
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        [viewController presentViewController:alertController animated:YES completion:nil];

    }];
    

}

+ (nonnull instancetype)alertControllerWithError:(nonnull NSError *)error
{
    TSCErrorRecoveryAttempter *recoveryAttempter = error.recoveryAttempter;
    
    NSString *overrideDescription = [TSCErrorRecoveryAttempter errorDescriptionStringForDomain:error.domain code:error.code];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:overrideDescription ?: error.localizedDescription message:[recoveryAttempter recoveryMessageBodyWithError:error] preferredStyle:UIAlertControllerStyleAlert];
    
    void (^alertActionHandler)(UIAlertAction *action) = ^(UIAlertAction *action) {
        
        NSUInteger optionIndex = [alertController.actions indexOfObject:action];
        
        [recoveryAttempter attemptRecoveryFromError:error optionIndex:optionIndex];
        
    };
    
    if (recoveryAttempter.recoveryOptions.count < 1) {
        
        [recoveryAttempter addOption:[TSCErrorRecoveryOption optionWithTitle:@"Dismiss" type:TSCErrorRecoveryOptionTypeCancel handler:nil]];
        
    }
    
    for (TSCErrorRecoveryOption *option in recoveryAttempter.recoveryOptions) {
        
        if (option.type == TSCErrorRecoveryOptionTypeCancel) {
            
            [alertController addAction:[UIAlertAction actionWithTitle:option.title style:UIAlertActionStyleCancel handler:alertActionHandler]];
            
        } else {
            
            [alertController addAction:[UIAlertAction actionWithTitle:option.title style:UIAlertActionStyleDefault handler:alertActionHandler]];

        }
        
    }
    
    return alertController;
}

@end
