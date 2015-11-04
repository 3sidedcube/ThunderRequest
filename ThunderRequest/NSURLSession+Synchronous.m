//
//  NSURLSession+Synchronous.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 04/11/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import "NSURLSession+Synchronous.h"

@implementation NSURLSession (Synchronous)

#pragma mark - Data Tasks
#pragma mark -

- (NSData *)sendSynchronousDataTaskWithRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    dispatch_semaphore_t taskSemaphore = dispatch_semaphore_create(0);
    __block NSData *returnData;
    
    [[self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {
        
        returnData = data;
        
        if (response && response != NULL) {
            *response = taskResponse;
        }
        
        if (error && error != NULL) {
            *error = taskError;
        }
        
        dispatch_semaphore_signal(taskSemaphore);
    }] resume];
    
    dispatch_semaphore_wait(taskSemaphore, DISPATCH_TIME_FOREVER);
    
    return returnData;
}

- (NSData *)sendSynchronousDataTaskWithURL:(NSURL *)url returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    return [self sendSynchronousDataTaskWithRequest:[NSURLRequest requestWithURL:url] returningResponse:response error:error];
}

#pragma mark - Upload Tasks
#pragma mark -

- (NSData *)sendSynchronousUploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    dispatch_semaphore_t taskSemaphore = dispatch_semaphore_create(0);
    __block NSData *returnData;
    
    [[self uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {
        
        returnData = data;
        
        if (response && response != NULL) {
            *response = taskResponse;
        }
        
        if (error && error != NULL) {
            *error = taskError;
        }
        
        dispatch_semaphore_signal(taskSemaphore);
        
    }] resume];
    
    dispatch_semaphore_wait(taskSemaphore, DISPATCH_TIME_FOREVER);
    
    return returnData;
}

- (NSData *)sendSynchronousUploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    dispatch_semaphore_t taskSemaphore = dispatch_semaphore_create(0);
    __block NSData *returnData;
    
    [[self uploadTaskWithRequest:request fromFile:fileURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {
        
        returnData = data;
        
        if (response && response != NULL) {
            *response = taskResponse;
        }
        
        if (error && error != NULL) {
            *error = taskError;
        }
        
        dispatch_semaphore_signal(taskSemaphore);
        
    }] resume];
    
    dispatch_semaphore_wait(taskSemaphore, DISPATCH_TIME_FOREVER);
    
    return returnData;
}

#pragma mark - Download Tasks
#pragma mark -

- (NSURL *)sendSynchronousDownloadTaskWithRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    dispatch_semaphore_t taskSemaphore = dispatch_semaphore_create(0);
    __block NSURL *returnURL;
    
    [[self downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {
        
        returnURL = location;
        
        if (response && response != NULL) {
            *response = taskResponse;
        }
        
        if (error && error != NULL) {
            *error = taskError;
        }
        
        dispatch_semaphore_signal(taskSemaphore);
        
    }] resume];
    
    dispatch_semaphore_wait(taskSemaphore, DISPATCH_TIME_FOREVER);
    
    return returnURL;
}

- (NSURL *)sendSynchronousDownloadTaskWithURL:(NSURL *)url returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    return [self sendSynchronousDownloadTaskWithRequest:[NSURLRequest requestWithURL:url] returningResponse:response error:error];
}

- (NSURL *)sendSynchronousDownloadTaskWithResumeData:(NSData *)resumeData returningResponse:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError *__autoreleasing  _Nullable *)error
{
    dispatch_semaphore_t taskSemaphore = dispatch_semaphore_create(0);
    __block NSURL *returnURL;
    
    [[self downloadTaskWithResumeData:resumeData completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {
        
        returnURL = location;
        
        if (response && response != NULL) {
            *response = taskResponse;
        }
        
        if (error && error != NULL) {
            *error = taskError;
        }
        
        dispatch_semaphore_signal(taskSemaphore);
        
    }] resume];
    
    dispatch_semaphore_wait(taskSemaphore, DISPATCH_TIME_FOREVER);
    
    return returnURL;
}

@end
