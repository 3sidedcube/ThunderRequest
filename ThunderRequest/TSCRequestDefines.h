typedef NS_ENUM(NSInteger, TSCRequestHTTPMethod) {
    TSCRequestHTTPMethodGET = 0,
    TSCRequestHTTPMethodPOST = 1,
    TSCRequestHTTPMethodPUT = 2,
    TSCRequestHTTPMethodDELETE = 3,
    TSCRequestHTTPMethodHEAD = 4
};

typedef NS_ENUM(NSInteger, TSCRequestContentType) {
    TSCRequestContentTypeJSON = 0,
    TSCRequestContentTypeFormURLEncoded = 1,
    TSCRequestContentTypeMultipartFormData = 2,
    TSCRequestContentTypeImagePNG = 3,
    TSCRequestContentTypeImageJPEG = 4
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
    TSCResponseStatusOK = 200,
    TSCResponseStatusCreated = 201,
    TSCResponseStatusAccepted = 202,
    TSCResponseStatusNonAuthoritativeInformation = 203,
    TSCResponseStatusNoContent = 204,
    TSCResponseStatusBadRequest = 400,
    TSCResponseStatusUnauthorized = 401,
    TSCResponseStatusPaymentRequired = 402,
    TSCResponseStatusForbidden = 403,
    TSCResponseStatusNotFound = 404,
    TSCResponseStatusMethodNotAllowed = 405,
    TSCResponseStatusNotAcceptable = 406,
    TSCResponseStatusInternalServerError = 500,
    TSCResponseStatusNotImplemented = 501,
    TSCResponseStatusBadGateway = 502,
    TSCResponseStatusServiceUnavailable = 503,
};