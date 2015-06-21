#import <Foundation/Foundation.h>

@class TSCErrorRecoveryOption;

/**
 An error recovery attempter is an object that conforms to the informal NSErrorRecoveryAttempting informal protocol. This attempter can be assigned to an error to help provide a way for the user to recover from an error
 */
@interface TSCErrorRecoveryAttempter : NSObject

/**
 @abstract An array of TSCErrorRecoveryOptions that the user can choose from to recover from an error
 */
@property (nonatomic, strong, nullable) NSMutableArray *recoveryOptions;

/** 
 @abstract The reason the failure occured. Optional
 */
@property (nonatomic, strong, nullable) NSString *failureReason;

/**
 @abstract The suggested method of recovery. Optional
 */
@property (nonatomic, strong, nullable) NSString *recoverySuggestion;

/**
 @abstract Should be called to generate an NSError with the error recovery attempter attatched. All other proprties should be set before calling this method
 */
- (nonnull NSError *)recoverableErrorWithError:(nonnull NSError *)error;

/**
 @abstract Returns a summarised message body to display to the user combining failure reasons and suggested recovery options if supplied
 @param error The NSError to attach to
 */
- (nonnull NSString *)recoveryMessageBodyWithError:(nonnull NSError *)error;

/**
 @abstract Adds an option to the list of ways a user can recover from the error
 @param option A recovery option object
 */
- (void)addOption:(nonnull TSCErrorRecoveryOption *)option;

/**
 Registers an override for a system error message. For example, CLGeocoder has very poor standard error mesaging. Registering an error through this method will ensure that this error message is used instead of the system one
 @param errorDescrion The description that you want to display to the user instead of the system one
 @param domain The domain of the error. Use constants where possible
 @param code The error code to override. Use constants where possible
 */
+ (void)registerOverrideDescription:(nullable NSString *)errorDescription forDomain:(nonnull NSString *)domain code:(NSInteger)errorCode;

/**
 Registers an override for a system error message. For example, CLGeocoder has very poor standard error mesaging. Registering an error through this method will ensure that this error message is used instead of the system one
 @param errorDescrion The description that you want to display to the user instead of the system one
 @param recoverySuggestion Advice to the user on how to recover from the error
 @param domain The domain of the error. Use constants where possible
 @param code The error code to override. Use constants where possible
 */
+ (void)registerOverrideDescription:(nullable NSString *)errorDescription recoverySuggestion:(nullable NSString *)recoverySuggestion forDomain:(nonnull NSString *)domain code:(NSInteger)errorCode;

/**
 Retrieves an override for an error key if there is one, and ignores it if not
 @param domain The domain of the error. Use constants where possible
 @param code The error code to override. Use constants where possible
 */
+ (nullable NSString *)errorDescriptionStringForDomain:(nonnull NSString *)domain code:(NSInteger)errorCode;

/**
 Retrieves an override for an error key if there is one, and ignores it if not
 @param domain The domain of the error. Use constants where possible
 @param code The error code to override. Use constants where possible
 */
+ (nullable NSString *)errorRecoveryStringForDomain:(nonnull NSString *)domain code:(NSInteger)errorCode;

@end
