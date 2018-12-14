#import "UIAlertController+TSCErrorRecoveryAttempter.h"
#import "TSCErrorRecoveryOption.h"
#import "TSCErrorRecoveryAttempter.h"

@implementation UIAlertController (TSCErrorRecoveryAttempter)

+ (void)presentError:(nonnull NSError *)error inViewController:(nonnull UIViewController *)viewController
{

}

+ (nonnull instancetype)alertControllerWithError:(nonnull NSError *)error
{
    return [UIAlertController alertControllerWithTitle:@"Hello" message:@"World" preferredStyle:UIAlertControllerStyleAlert];
}

@end
