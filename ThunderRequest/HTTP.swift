//
//  HTTP.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A protocol which can be conformed to in order to send any object as a HTTP request
protocol RequestBody {
    
    var contentType: String? { get }
    
    func data() -> Data?
}

///// An enum providing standard values for the `Content-Type` header.
/////
///// - json: JSON
///// - formURLEncoded: Body is encoded into the request url
///// - multipartFormData: Body is encoded as multi-part form data
///// - image: Body is image data
///// - XMLPlist: Body is an xml plist
///// - urlArguments: Body is url arguments
///// - custom: Body is a custom content type, must provide it's string value and a mutating function for the request
//enum ContentType {
//    
//    case json
//    case formURLEncoded
//    case multipartFormData
//    case image(String)
//    case XMLPlist
//    case urlArguments
//    case custom(String)
//    case video(String)
//    case plainText
//    
//    func stringValue(body: Any?) -> String? {
//        
//        switch self {
//        case .json:
//            return "application/json"
//        case .formURLEncoded:
//            return "application/x-www-form-urlencoded"
//        case .XMLPlist:
//            return "text/x-xml-plist"
//        case .urlArguments:
//            return "text/x-url-arguments"
//        case .image(let format):
//            return "image/\(format)"
//        case .video(let format):
//            return "video/\(format)"
//        case .custom(let value):
//            return value
//        case .plainText:
//            return "text/plain"
//        case .multipartFormData:
//            guard let body = body else {
//                return nil
//            }
//            return "multipart/form-data; boundary=\(multipartFormBoundary(body:body))"
//        }
//    }
//    
//    internal func multipartFormBoundary(body: Any) -> String {
//        return String(describing: body).md5Hex ?? ""
//    }
//}

public struct HTTP {
    /// Enum representing HTTP Methods
    ///
    /// - CONNECT: The CONNECT method establishes a tunnel to the server identified by the target resource.
    /// - DELETE: The DELETE method deletes the specified resource.
    /// - GET: The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
    /// - HEAD: The HEAD method asks for a response identical to that of a GET request, but without the response body.
    /// - OPTIOSN: The OPTIONS method is used to describe the communication options for the target resource.
    /// - PATCH: The PATCH method is used to apply partial modifications to a resource.
    /// - POST: The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    /// - PUT: The PUT method replaces all current representations of the target resource with the request payload.
    /// - TRACE: The TRACE method performs a message loop-back test along the path to the target resource.
    public enum Method: String {
        case CONNECT
        case DELETE
        case GET
        case HEAD
        case OPTIONS
        case PATCH
        case POST
        case PUT
        case TRACE
    }
}
