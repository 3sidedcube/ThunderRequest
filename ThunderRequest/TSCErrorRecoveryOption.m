#import "TSCErrorRecoveryOption.h"

@interface TSCErrorRecoveryOption ()

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title type:(TSCErrorRecoveryOptionType)type handler:(nonnull TSCErrorRecoveryOptionHandler)handler;

@end

@implementation TSCErrorRecoveryOption

+ (nonnull instancetype)optionWithTitle:(nonnull NSString *)title type:(TSCErrorRecoveryOptionType)type handler:(nullable TSCErrorRecoveryOptionHandler)handler
{
    return [[TSCErrorRecoveryOption alloc] initWithTitle:title type:type handler:handler];
}

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title type:(TSCErrorRecoveryOptionType)type handler:(nonnull TSCErrorRecoveryOptionHandler)handler
{
    self = [super init];
    if (self) {
        
        _title = title;
        _type = type;
        _handler = handler;

    }
    
    return self;
}

@end
