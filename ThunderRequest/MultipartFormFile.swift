//
//  MultipartFormFile.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public struct MultipartFormFile: MultipartFormElement {
    
    let fileData: Data
    
    let contentType: String
    
    let fileName: String
    
    let disposition: String?
    
    let name: String?
    
    let transferEncoding: String?
    
    init(fileData: Data, contentType: String, fileName: String, disposition: String? = nil, name: String? = nil, transferEncoding: String? = nil) {
        
        self.fileData = fileData
        self.contentType = contentType
        self.fileName = fileName
        self.disposition = disposition
        self.name = name
        self.transferEncoding = transferEncoding
    }
    
    public func multipartDataWith(boundary: String, key: String) -> Data? {
        
        var dataString = "--\(boundary)\r\nContent-Disposition: \(disposition ?? "form-data");"
        dataString.append("name=\"\(name ?? key)\";")
        dataString.append(" filename=\"\(fileName)\"\r\n")
        dataString.append("Content-Type: \(contentType)\r\n")
        dataString.append("Content-Transfer-Encoding: \(transferEncoding ?? "binary")\r\n\r\n")
        
        var returnData = dataString.data(using: .utf8)
        returnData?.append(fileData)
        returnData?.append("\r\n")
        returnData?.append("--\(boundary)")
        
        return returnData
    }
}
