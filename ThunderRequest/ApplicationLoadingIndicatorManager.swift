//
//  ApplicationLoadingIndicatorManager.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 13/04/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import UIKit

open class ApplicationLoadingIndicatorManager: NSObject {
    
    open static let sharedManager = ApplicationLoadingIndicatorManager()
    fileprivate var activityCount = 0
        
    open func showActivityIndicator() {
        
        objc_sync_enter(self)
        if activityCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        activityCount += 1
        objc_sync_exit(self)
    }
    
    open func hideActivityIndicator() {
        
        objc_sync_enter(self)
        activityCount -= 1
        if activityCount <= 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        objc_sync_exit(self)
    }
}
