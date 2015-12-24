//
//  TSCRequestDefines.m
//  ThunderRequest
//
//  Created by Matthew Cheetham on 02/09/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import Foundation;

NSString *const TSCRequestErrorDomain = @"com.threesidedcube.ThunderRequest";
NSString *const TSCRequestServerError = @"TSCRequestServerError";
NSString *const TSCRequestDidReceiveResponse = @"TSCRequestDidReceiveResponse";

NSString *const TSCMultipartFormDataDataKey = @"TSC_MPFD_DATA";
NSString *const TSCMultipartFormDataFilenameKey = @"TSC_MPFD_FILENAME";
NSString *const TSCMultipartFormDataNameKey = @"TSC_MPFD_NAME";
NSString *const TSCMultipartFormDataDispositionKey = @"TSC_MPFD_DISPOSITION";