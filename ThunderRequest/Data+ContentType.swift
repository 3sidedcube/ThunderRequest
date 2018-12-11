//
//  ContentType+Data.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation



extension Data {
    
    var contentType: String? {
        
        guard count > 0 else { return nil }
        let firstByte = self[0]
        switch firstByte {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x00:
            return "video/quicktime"
        case 0x44:
            return "text/plain"
        default:
            return nil
        }
    }
    
    var fileExtension: String? {
        
        switch contentType {
        case "image/jpeg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/tiff":
            return "tiff"
        case "text/plain":
            return "txt"
        case "video/quicktime":
            return "mov"
        default:
            return nil
        }
    }
}

//extension Request.ContentType {
//    
//    /// Returns the body data to be used with an `NSURLRequest` formatted according to the specific content type
//    ///
//    /// - Parameter body: The body object to be converted to `Data`
//    /// - Returns: a data object if one could be constructed
//    internal func data(from body: Any) throws -> Data? {
//        
//        switch self {
//        case .json:
//            do {
//                let data = try jsonData(from: body)
//                return data
//            } catch let error {
//                throw error
//            }
//        case .formURLEncoded:
//            guard let dictionary = body as? Dictionary<AnyHashable, Any> else {
//                throw RequestBodyError.invalidBodyForContentType
//            }
//            guard let data = dictionary.queryParameterData else {
//                throw RequestBodyError.invalidBodyForContentType
//            }
//            return data
//        case .multipartFormData:
//            
//            guard let dictionary = body as? Dictionary<AnyHashable, Any> else {
//                throw RequestBodyError.invalidBodyForContentType
//            }
//            
//            let boundary = self.multipartFormBoundary(body: dictionary)
//            
//            var data = Data()
//            dictionary.forEach { (keyValue) in
//                guard let partData = multipartDataFor(element: keyValue.value, key: String(describing: keyValue.key), boundary: boundary) else {
//                    return
//                }
//                data.append(partData)
//            }
//            
//            return data
//            
//        default:
//            return nil
//        }
//    }
//    
//    private func jsonData(from body: Any) throws -> Data? {
//        
//        guard JSONSerialization.isValidJSONObject(body) else {
//            throw RequestBodyError.invalidBodyForContentType
//        }
//        
//        do {
//            let data = try JSONSerialization.data(withJSONObject: body, options: [])
//            return data
//        } catch let error {
//            throw error
//        }
//    }
//    
//    private func multipartDataFor(element: Any, key: String, boundary: String) -> Data? {
//        
//        let boundaryString = "--\(boundary)"
//        
//        if let string = element as? String {
//            return "\(boundaryString)\r\nContent-Disposition: form-   ; name=\"\(key)\"\r\n\(string)\r\n".data(using: .utf8)
//        }
//        
//        let object = Data(any: element) ?? element
//        
//        switch object {
//        case let data as Data:
//            
//            guard let contentType = data.contentType, let contentTypeString = contentType.stringValue(body: object) else {
//                return nil
//            }
//            guard let fileExtension = contentType.fileExtension else {
//                return nil
//            }
//            
//            var returnData = Data()
//            returnData.append("\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"; filename=\"filename.\(fileExtension)\"\r\n")
//            returnData.append("Content-Type: \(contentTypeString)\r\n")
//            returnData.append("Content-Transfer-Encoding: \(binary)\r\n\r\n", using: <#T##String.Encoding#>)
//            
//        default:
//            <#code#>
//        }
//    }
//}

enum RequestBodyError: Error {
    case invalidBodyForContentType
}
