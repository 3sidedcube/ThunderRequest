#import <Foundation/Foundation.h>
#import "TSCRequestDefines.h"

/**
 An option to be added to a TSCErrorRecoveryAttempter. When the attempter presents the alert on screen to the user. Each one of the options added will be displayed as a selectable button for the user
 */
@interface TSCErrorRecoveryOption : NSObject

typedef void (^TSCErrorRecoveryOptionHandler)(TSCErrorRecoveryOption * __nonnull option);

/**
 @abstract The title of the recovery option button.
 */
@property (nonatomic, readonly, nonnull) NSString *title;

/**
 @abstract The type that is applied to the recovery option
 */
@property (nonatomic, readonly) TSCErrorRecoveryOptionType type;

/**
 @abstract A block to execute when the user selects the recovery option. If none is supplied then the alert dialog will simply dismiss when this option is selected
 */
@property (nonatomic, readonly, nullable) TSCErrorRecoveryOptionHandler handler;

/**
 @abstract Intialises a new option
 @param title The title to display on the button
 @param type The type of the button, whether it is a retry, cancel or custom
 @param handler The handler to fire if the option is selected
 */
+ (nonnull instancetype)optionWithTitle:(nonnull NSString *)title type:(TSCErrorRecoveryOptionType)type handler:(nullable TSCErrorRecoveryOptionHandler)handler;

@end
