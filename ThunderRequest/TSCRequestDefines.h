extern NSString *const TSCRequestErrorDomain;
extern NSString *const TSCRequestServerError;
extern NSString *const TSCRequestDidReceiveResponse;

extern NSString *const TSCRequestNotificationRequestKey;
extern NSString *const TSCRequestNotificationResponseKey;

extern NSString *const TSCMultipartFormDataDataKey;
extern NSString *const TSCMultipartFormDataFilenameKey;
extern NSString *const TSCMultipartFormDataNameKey;
extern NSString *const TSCMultipartFormDataDispositionKey;

typedef NS_ENUM(NSInteger, TSCRequestHTTPMethod) {
    TSCRequestHTTPMethodGET = 0,
    TSCRequestHTTPMethodPOST = 1,
    TSCRequestHTTPMethodPUT = 2,
    TSCRequestHTTPMethodDELETE = 3,
    TSCRequestHTTPMethodHEAD = 4,
    TSCRequestHTTPMethodPATCH = 5
};

typedef NS_ENUM(NSInteger, TSCRequestContentType) {
    TSCRequestContentTypeUndefined = 0,
    TSCRequestContentTypeJSON = 1,
    TSCRequestContentTypeFormURLEncoded = 2,
    TSCRequestContentTypeMultipartFormData = 3,
    TSCRequestContentTypeImagePNG = 4,
    TSCRequestContentTypeImageJPEG = 5,
    TSCRequestContentTypeXMLPlist = 6,
    TSCRequestContentTypeURLArguments = 7
};

/** The styles available for a `TSCErrorRecoveryOption` */
typedef NS_ENUM(NSInteger, TSCErrorRecoveryOptionType) {
    /** A custom option for recovering from an error */
    TSCErrorRecoveryOptionTypeCustom = 0,
    /** An option to display a retry button and repeat the request where possible */
    TSCErrorRecoveryOptionTypeRetry = 1,
    /** The 'cancel' option that dismisses the recovery */
    TSCErrorRecoveryOptionTypeCancel = 2
};

typedef NS_ENUM(NSInteger, TSCResponseStatus) {
    TSCResponseStatusContinue = 100,
    TSCResponseStatusSwitchingProtocols = 101,
    TSCResponseStatusOK = 200,
    TSCResponseStatusCreated = 201,
    TSCResponseStatusAccepted = 202,
    TSCResponseStatusNonAuthoritativeInformation = 203,
    TSCResponseStatusNoContent = 204,
    TSCResponseStatusResetContent = 205,
    TSCResponseStatusPartialContent = 206,
    TSCResponseStatusMultipleChoices = 300,
    TSCResponseStatusMovedPermanently = 301,
    TSCResponseStatusFound = 302,
    TSCResponseStatusSeeOther = 303,
    TSCResponseStatusNotModified = 304,
    TSCResponseStatusUseProxy = 305,
    TSCResponseStatusTemporaryRedirect = 307,
    TSCResponseStatusBadRequest = 400,
    TSCResponseStatusUnauthorized = 401,
    TSCResponseStatusPaymentRequired = 402,
    TSCResponseStatusForbidden = 403,
    TSCResponseStatusNotFound = 404,
    TSCResponseStatusMethodNotAllowed = 405,
    TSCResponseStatusNotAcceptable = 406,
    TSCResponseStatusProxyAuthenticationRequired = 407,
    TSCResponseStatusRequestTimeout = 408,
    TSCResponseStatusConflict = 409,
    TSCResponseStatusGone = 410,
    TSCResponseStatusLengthRequired = 411,
    TSCResponseStatusPreconditionFailed = 412,
    TSCResponseStatusRequestEntityTooLarge = 413,
    TSCResponseStatusRequestURITooLong = 414,
    TSCResponseStatusUnsupportedMediaType = 415,
    TSCResponseStatusRangeNotSatisfiable = 416,
    TSCResponseStatusExpectationFailed = 417,
    TSCResponseStatusImATeapot = 418,
    TSCResponseStatusAuthenticationTimeout = 419,
    TSCResponseStatusInternalServerError = 500,
    TSCResponseStatusNotImplemented = 501,
    TSCResponseStatusBadGateway = 502,
    TSCResponseStatusServiceUnavailable = 503,
    TSCResponseStatusGatewayTimeout = 504,
    TSCResponseStatusHTTPVersionNotSupported = 505
};
