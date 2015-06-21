#import <UIKit/UIKit.h>

/**
 Assists TSCErrorRecoveryAttempter with the display of errors that conform to the informal protocol of NSErrorRecoveryAttempter
 */
@interface UIAlertController (TSCErrorRecoveryAttempter)

/**
 @abstract Handles presenting of an error with a single method. Automatically creates error recovery attempters and displays 
 @param error The error to display
 @param viewController The view controller to use for presentation
 */
+ (void)presentError:(nonnull NSError *)error inViewController:(nonnull UIViewController *)viewController;

/**
 @abstract Creates an alert controller from an NSError
 @param error An error that has a TSCErrorRecoveryAttempter assigned to it
 */
+ (nonnull instancetype)alertControllerWithError:(nonnull NSError *)error;

@end
