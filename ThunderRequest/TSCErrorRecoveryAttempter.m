#import "TSCErrorRecoveryAttempter.h"
#import "TSCErrorRecoveryOption.h"

@implementation TSCErrorRecoveryAttempter

- (nonnull NSError *)recoverableErrorWithError:(nonnull NSError *)error
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    userInfo[NSRecoveryAttempterErrorKey] = self;
    userInfo[NSLocalizedRecoveryOptionsErrorKey] = [self recoveryOptionTitles];
    
    if (!self.recoverySuggestion) {
        
        self.recoverySuggestion = [TSCErrorRecoveryAttempter errorRecoveryStringForDomain:error.domain code:error.code];
        
    }
    
    if (self.failureReason.length) userInfo[NSLocalizedFailureReasonErrorKey] = self.failureReason;
    if (self.recoverySuggestion.length) userInfo[NSLocalizedRecoverySuggestionErrorKey] = self.recoverySuggestion;
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

- (nonnull NSArray *)recoveryOptionTitles
{
    NSMutableArray *titles = [NSMutableArray array];
    
    for (TSCErrorRecoveryOption *option in self.recoveryOptions) {
        
        [titles addObject:option.title];
        
    }
    
    return titles;
}

- (nonnull NSString *)recoveryMessageBodyWithError:(nonnull NSError *)error
{
    NSMutableString *recoveryBody = [NSMutableString string];
    
    if (error.localizedFailureReason) {
        [recoveryBody appendFormat:@"\n%@", error.localizedFailureReason];
    }
    
    if (error.localizedRecoverySuggestion) {
        [recoveryBody appendFormat:@"\n%@", error.localizedRecoverySuggestion];
    }
    
    return recoveryBody;

}
#pragma mark - Action handling

- (void)addOption:(nonnull TSCErrorRecoveryOption *)option
{
    NSMutableArray *options = [NSMutableArray arrayWithArray:self.recoveryOptions];
    [options addObject:option];
    self.recoveryOptions = options;
}

#pragma mark - Recovery attempting

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex
{
    TSCErrorRecoveryOption *option = self.recoveryOptions[recoveryOptionIndex];
    
    if (option.handler) {
        
        option.handler(option);
        
    }
    return YES;
}

- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo
{
    [self attemptRecoveryFromError:error optionIndex:recoveryOptionIndex];
}

#pragma mark - Register overrides

+ (void)registerOverrideDescription:(nullable NSString *)errorDescription forDomain:(nonnull NSString *)domain code:(NSInteger)errorCode
{
    [TSCErrorRecoveryAttempter registerOverrideDescription:errorDescription recoverySuggestion:nil forDomain:domain code:errorCode];
}

+ (void)registerOverrideDescription:(nullable NSString *)errorDescription recoverySuggestion:(nullable NSString *)recoverySuggestion forDomain:(nonnull NSString *)domain code:(NSInteger)errorCode
{
    NSString *errorDescriptionKey = [NSString stringWithFormat:@"%@%liDescription", domain, (long)errorCode];
    NSString *errorRecoveryKey = [NSString stringWithFormat:@"%@%liRecovery", domain, (long)errorCode];

    NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"TSCErrorRecoveryOverrides"]];
    
    if (errorDescription) {
        errorDictionary[errorDescriptionKey] = errorDescription;
    }
    
    if (recoverySuggestion) {
        errorDictionary[errorRecoveryKey] = recoverySuggestion;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:errorDictionary forKey:@"TSCErrorRecoveryOverrides"];
}

+ (nullable NSString *)errorDescriptionStringForDomain:(nonnull NSString *)domain code:(NSInteger)errorCode
{
    NSString *errorKey = [NSString stringWithFormat:@"%@%liDescription", domain, (long)errorCode];

    NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"TSCErrorRecoveryOverrides"]];

    return errorDictionary[errorKey];
}

+ (nullable NSString *)errorRecoveryStringForDomain:(nonnull NSString *)domain code:(NSInteger)errorCode
{
    NSString *errorKey = [NSString stringWithFormat:@"%@%liRecovery", domain, (long)errorCode];
    
    NSMutableDictionary *errorDictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"TSCErrorRecoveryOverrides"]];
    
    return errorDictionary[errorKey];
}

@end
