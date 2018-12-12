//
//  RequestController+Callbacks.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

extension RequestController {
    
    func add(completionHandler: TransferCompletion?, progressHandler: ProgressHandler?, forTaskId taskId: Int) {
        
        if transferCompletionHandlers[taskId] != nil {
//            os_log_error(request_controller_log, "Error: Got multiple handlers for a single task identifier.  This should not happen.\n");
        }
        
        transferCompletionHandlers[taskId] = completionHandler
        
        if progressHandlers[taskId] != nil {
//            os_log_error(request_controller_log, "Error: Got multiple progress handlers for a single task identifier.  This should not happen.\n");
        }
        
        progressHandlers[taskId] = progressHandler
    }
    
    func callProgressHandlerFor(taskIdentifier: Int, progress: Double, totalBytes: Int64, progressBytes: Int64) {
        progressHandlers[taskIdentifier]?(progress, totalBytes, progressBytes)
    }
    
    func callCompletionHandlersFor(taskIdentifier: Int, downloadedFileURL fileURL: URL?, error: Error?) {
        
        transferCompletionHandlers[taskIdentifier]?(fileURL, error)
        transferCompletionHandlers[taskIdentifier] = nil
        progressHandlers[taskIdentifier] = nil
    }
}
