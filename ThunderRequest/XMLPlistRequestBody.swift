//
//  JSONRequestBody.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A request body struct which can be used to represent the payload of a
/// Plist object
public struct PropertyListRequestBody: RequestBody {
    
    /// The xml plist object that should be sent with the request
    let propertyList: Any
    
    /// The format to send the plist as
    let format: PropertyListSerialization.PropertyListFormat
    
    /// Creates a new Plist upload request body
    ///
    /// - Parameters:
    ///   - propertyList: The Plist to send
    ///   - format: (optional) How to format the plist
    init(_ propertyList: Any, format: PropertyListSerialization.PropertyListFormat = .xml) {
        self.propertyList = propertyList
        self.format = format
    }
    
    public var contentType: String? {
        return "text/x-xml-plist"
    }
    
    public func payload() -> Data? {
        return try? PropertyListSerialization.data(fromPropertyList: propertyList, format: format, options: 0)
    }
}
