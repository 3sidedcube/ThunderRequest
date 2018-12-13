//
//  RequestController.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public typealias RequestCompletion = (_ response: RequestResponse?, _ error: Error?) -> Void
public typealias TransferCompletion = (_ response: RequestResponse?, _ fileLocation: URL?, _ error: Error?) -> Void
public typealias ProgressHandler = (_ progress: Double, _ totalBytes: Int64, _ transferredBytes: Int64) -> Void

/// An instance of `RequestController` lets you asynchronously perform HTTP requests with a closure being called upn completion.
///
/// The `RequestController` object should be retained if needed for use with multiple requests. Generally one `RequestController` should be initialised and shared per API/Base URL.
///
/// To use a `RequestController` do the following
///
/// 1. Create a property with the type `RequestController`
/// 2. Initialise a new controller with the `init(baseURL:)` method
/// 3. Use any of the GET/POST e.t.c. methods to perform requests
///
/// IMPORTANT --- `RequestController` uses URLSession internally which hold a strong reference to their delegate. You must therefore call `invalidateAndCancel` when done with your `RequestController` object.
public class RequestController {
    
    /// The shared Base URL for all requests routed through the controller
    ///
    /// This is most commonly set via the init(baseURL:) method
    public var sharedBaseURL: URL
    
    /// A custom queue to dispatch all request callbacks onto
    public var callbackQueue: DispatchQueue?
    
    /// The request controller for making OAuth2 re-authentication requests on
    public var OAuth2RequestController: RequestController?
    
    /// The user is re-authenticating
    var reAuthenticating: Bool = false
    
    /// The shared request headers for all requests routed through the controller
    public var sharedRequestHeaders: [String : String?] = [:]
    
    /// The shared request credentials to be used for authorization with any authentication challenge
    public var sharedRequestCredentials: TSCRequestCredential?
    
    /// The OAuth2 delegate which will respond to OAuth2 unauthenticated responses e.t.c.
    public var oAuth2Delegate: TSCOAuth2Manager?
    
    /// An array of requests that were sent whilst waiting for an authentication callback.
    var requestsQueuedForAuthentication: [(Request, RequestCompletion?)] = []
    
    /// Can be used to force synchronous behaviour of the request controller.
    ///
    /// This should not be done with requests running on the main thread. The primary use case
    /// for this functionality was to support HTTP requests in OSX CLI.
    /// - Warning: Setting this to true could cause un-expected behaviours
    public var runSynchronously: Bool = false
    
    /// The operation queue that contains all requests added to a default session
    private var defaultRequestQueue = OperationQueue()
    
    /// The operation queue that contains all requests added to a background session
    private var backgroundRequestQueue = OperationQueue()
    
    /// The operation queue that contains all requests added to a ephemeral session
    private var ephemeralRequestQueue = OperationQueue()
    
    /// Uses persistent disk-based cache and stores credentials in the user's keychain
    private var defaultSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    /// Does not store any data on the disk; all caches, credential stores, and so on are kept in the RAM and tied
    /// to the session. Thus, when invalidated, they are purged automatically.
    private var backgroundSession: URLSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: ""))
    
    /// Similar to a default session, except that a seperate process handles all data transfers. Background sessions have some additional limitations.
    private var ephemeralSession: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    ///MARK: - Initialization -
    
    /// Initialises a request controller with a given base URL
    ///
    /// - Parameter baseURL: The base URL to use for all requests
    public init(baseURL: URL) {
        
        if baseURL.absoluteString.hasSuffix("/") {
            sharedBaseURL = baseURL
        } else {
            sharedBaseURL = URL(string: baseURL.absoluteString.appending("/")) ?? baseURL
        }
        
        sharedRequestCredentials = TSCRequestCredential.retrieveCredential(withIdentifier: "thundertable.com.threesidedcube-\(sharedBaseURL)")
        resetSessions()
    }
    
    /// Initialises a request controller with a given base address
    ///
    /// - Parameter baseAddress: The base address to use for all requests
    public convenience init?(baseAddress: String) {
        guard let url = URL(string: baseAddress) else { return nil }
        self.init(baseURL: url)
    }
    
    /// Sets the user agent to be used for all instances of RequestController
    ///
    /// - Parameter userAgent: The string to set the request controller's user agent to
    static func set(userAgent: String?) {
        if let userAgent = userAgent {
            UserDefaults.standard.set(userAgent, forKey: "TSCUserAgent")
        } else {
            UserDefaults.standard.removeObject(forKey: "TSCUserAgent")
        }
    }
    
    private var sessionDelegate: SessionDelegateProxy?
    
    var transferCompletionHandlers: [Int : TransferCompletion] = [:]
    
    var completionHandlers: [Int : RequestCompletion] = [:]
    
    var progressHandlers: [Int : ProgressHandler] = [:]
    
    var redirectResponses: [AnyHashable : HTTPURLResponse] = [:]
    
    private func resetSessions() {
        
        defaultRequestQueue = OperationQueue()
        backgroundRequestQueue = OperationQueue()
        ephemeralRequestQueue = OperationQueue()
        
        sessionDelegate = SessionDelegateProxy(delegate: self)
        
        let defaultConfig = URLSessionConfiguration.default
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
        let ephemeralConfig = URLSessionConfiguration.ephemeral
        
        defaultSession = URLSession(configuration: defaultConfig, delegate: sessionDelegate, delegateQueue: defaultRequestQueue)
        backgroundSession = URLSession(configuration: backgroundConfig, delegate: sessionDelegate, delegateQueue: backgroundRequestQueue)
        ephemeralSession = URLSession(configuration: ephemeralConfig, delegate: nil, delegateQueue: ephemeralRequestQueue)
        
        transferCompletionHandlers = [:]
        completionHandlers = [:]
        progressHandlers = [:]
    }
    
    //MARK: - Making Requests -
    //MARK: General Requests
    
    private func setHeaders(_ headers: [String: String?]?, for request: Request) {
        
        var allHeaders = sharedRequestHeaders
        
        // In some APIs an error will be returned if you set a Content-Type header
        // but don't pass a body (In the case of a GET request you never pass a body)
        // so for GET requests we nil this out
        if request.method == .GET {
            allHeaders["Content-Type"] = nil
        }
        
        if let headers = headers {
            allHeaders.merge(headers, uniquingKeysWith: { (key1, key2) in
                return key1
            })
        }
        
        request.headers = allHeaders
    }
    
    /// Performs a HTTP request to the given path using the parameters provided
    ///
    /// If you already have a `Request` object, use one of the `schedule` methods instead.
    ///
    /// - Parameters:
    ///   - path: The path to append to `sharedBaseURL`
    ///   - method: The HTTP method to use for the request
    ///   - body: The body to be sent with the request
    ///   - tag: A tag to apply to the request so it can be cancelled later
    ///   - contentType: (Optional) an override to the content type provided by `body`
    ///   - overrideURL: (Optional) an override for `sharedBaseURL`
    ///   - queryItems: (Optional) query items to append to the url
    ///   - headers: (Optional) a dictionary of override headers to be merged with `sharedRequestHeaders`
    ///   - completion: (Optional) A closure to be called once the request has completed
    /// - Returns: The request object that will be run
    @discardableResult public func request(
        _ path: String?,
        method: HTTP.Method,
        body: RequestBody? = nil,
        tag: Int = Int.random(in: 0...1000),
        contentType: String? = nil,
        overrideURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String?]? = nil,
        completion: RequestCompletion?) -> Request {
        
        let request = Request(
            baseURL: overrideURL ?? sharedBaseURL,
            path: path,
            method: method,
            queryItems: queryItems
        )
        request.contentType = contentType
        request.body = body
        request.tag = tag
        
        setHeaders(headers, for: request)
        schedule(request: request, completion: completion)
        
        return request
    }
    
    //MARK: Uploads
    /// Performs a HTTP request to upload the file at a given file url to a given path
    ///
    /// If you already have a `Request` object, use one of the `schedule` methods instead.
    ///
    /// - Parameters:
    ///   - fileURL: The file to upload
    ///   - path: The path to append to `sharedBaseURL`
    ///   - tag: A tag to apply to the request so it can be cancelled later
    ///   - contentType: (Optional) an override to the content type provided by `body`
    ///   - overrideURL: (Optional) an override for `sharedBaseURL`
    ///   - queryItems: (Optional) query items to append to the url
    ///   - headers: (Optional) a dictionary of override headers to be merged with `sharedRequestHeaders`
    ///   - progress: (Optional) A closure to be called as the upload progresses
    ///   - completion: (Optional) A closure to be called once the upload has completed
    /// - Returns: The request which has been made
    @discardableResult public func uploadFile(
        _ fileURL: URL,
        to path: String?,
        tag: Int = Int.random(in: 0...1000),
        contentType: String? = nil,
        overrideURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String?]? = nil,
        progress: ProgressHandler?,
        completion: TransferCompletion?
    ) -> Request {
        
        let request = Request(
            baseURL: overrideURL ?? sharedBaseURL,
            path: path,
            method: .POST,
            queryItems: queryItems
        )
        request.contentType = contentType
        request.tag = tag
        setHeaders(headers, for: request)
        
        scheduleUpload(request, on: nil, fileURL: fileURL, progress: progress, completion: completion)
        
        return request
    }
    
    /// Performs a HTTP request to upload some given data
    ///
    /// If you already have a `Request` object, use one of the `schedule` methods instead.
    ///
    /// - Parameters:
    ///   - data: The data to upload
    ///   - path: The path to append to `sharedBaseURL`
    ///   - tag: A tag to apply to the request so it can be cancelled later
    ///   - contentType: (Optional) an override to the content type provided by `body`
    ///   - overrideURL: (Optional) an override for `sharedBaseURL`
    ///   - queryItems: (Optional) query items to append to the url
    ///   - headers: (Optional) a dictionary of override headers to be merged with `sharedRequestHeaders`
    ///   - progress: (Optional) A closure to be called as the upload progresses
    ///   - completion: (Optional) A closure to be called once the upload has completed
    /// - Returns: The request which has been made
    @discardableResult public func uploadData(
        _ data: Data,
        to path: String?,
        tag: Int = Int.random(in: 0...1000),
        contentType: String? = nil,
        overrideURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String?]? = nil,
        progress: ProgressHandler?,
        completion: TransferCompletion?
    ) -> Request {
        
        let request = Request(
            baseURL: overrideURL ?? sharedBaseURL,
            path: path,
            method: .POST,
            queryItems: queryItems
        )
        
        guard let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else {
            // TODO: Send error as last parameter
            completion?(nil, nil, nil)
            return request
        }
        
        let cacheURL = URL(fileURLWithPath: cachesDirectory).appendingPathComponent(NSUUID().uuidString)
        
        do {
            try data.write(to: cacheURL)
        } catch let error {
            completion?(nil, nil, error)
            return request
        }
        
        request.contentType = contentType
        request.tag = tag
        //TODO: Make `Data` conform to RequestBody
//        request.body = data
        setHeaders(headers, for: request)
        
        scheduleUpload(request, on: nil, fileURL: cacheURL, progress: progress, completion: completion)
        
        return request
    }
    
    /// Performs a HTTP request to upload to the given path using the parameters provided
    ///
    /// If you already have a `Request` object, use one of the `schedule` methods instead.
    ///
    /// - Parameters:
    ///   - path: The path to append to `sharedBaseURL`
    ///   - body: The body to be uploaded
    ///   - tag: A tag to apply to the upload so it can be cancelled later
    ///   - contentType: (Optional) an override to the content type provided by `body`
    ///   - overrideURL: (Optional) an override for `sharedBaseURL`
    ///   - queryItems: (Optional) query items to append to the url
    ///   - headers: (Optional) a dictionary of override headers to be merged with `sharedRequestHeaders`
    ///   - progress: (Optional) A closure to be called as the upload progresses
    ///   - completion: (Optional) A closure to be called once the upload has completed
    /// - Returns: The request object that will be run
    @discardableResult public func upload(
        _ path: String?,
        body: RequestBody?,
        tag: Int = Int.random(in: 0...1000),
        contentType: String? = nil,
        overrideURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String?]? = nil,
        progress: ProgressHandler?,
        completion: TransferCompletion?) -> Request {
        
        let request = Request(
            baseURL: overrideURL ?? sharedBaseURL,
            path: path,
            method: .POST,
            queryItems: queryItems
        )
        request.contentType = contentType
        request.body = body
        request.tag = tag
        
        setHeaders(headers, for: request)
        scheduleUpload(request, on: nil, fileURL: nil, progress: progress, completion: completion)
        
        return request
    }
    
    //MARK: Download
    
    /// Performs a HTTP request to download from the given path using the parameters provided
    ///
    /// If you already have a `Request` object, use one of the `schedule` methods instead.
    ///
    /// - Parameters:
    ///   - path: The path to append to `sharedBaseURL`
    ///   - on: The date to schedule the download on
    ///   - tag: A tag to apply to the download so it can be cancelled later\
    ///   - overrideURL: (Optional) an override for `sharedBaseURL`
    ///   - queryItems: (Optional) query items to append to the url
    ///   - headers: (Optional) a dictionary of override headers to be merged with `sharedRequestHeaders`
    ///   - progress: (Optional) A closure to be called as the download progresses
    ///   - completion: (Optional) A closure to be called once the download has completed
    /// - Returns: The request object that will be run
    @discardableResult public func download(
        _ path: String?,
        on: Date? = nil,
        tag: Int = Int.random(in: 0...1000),
        overrideURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String?]? = nil,
        progress: ProgressHandler?,
        completion: TransferCompletion?) -> Request {
        
        let request = Request(
            baseURL: overrideURL ?? sharedBaseURL,
            path: path,
            method: .GET,
            queryItems: queryItems
        )
        request.tag = tag
        
        setHeaders(headers, for: request)
        scheduleDownload(request, on: on, progress: progress, completion: completion)
        
        return request
    }
    
    //MARK: - Scheduling Requests -
    //MARK: General
    
    /// Schedules a `Request` object to be made using the `URLSession`.
    ///
    /// - Parameters:
    ///   - request: The request to be made.
    ///   - completion: A closure to be called once the request has finished.
    public func schedule(request: Request, completion: RequestCompletion?) {
        
        // Set activity indicator (Only if we're the first request)
        RequestController.showApplicationActivityIndicator()
        
        if let userAgent = UserDefaults.standard.string(forKey: "TSCUserAgent"), !request.headers.keys.contains("User-Agent") {
            request.headers["User-Agent"] = userAgent
        }
        
        checkOAuthStatusFor(request: request) { [weak self] (authenticated, error, needsQueueing) in
            
            if let error = error, !authenticated, !needsQueueing {
                
                RequestController.hideApplicationActivityIndicator()
                completion?(nil, error)
                return
            }
            
            guard let self = self else { return }
            
            if needsQueueing {
                // If we're not authenticated but didn't get an error,
                // then our request came inbetween calling re-authentication and getting a response
                self.requestsQueuedForAuthentication.append((request, completion))
            }
            
            do {
                
                var urlRequest = try request.construct()
                
                if self.runSynchronously {
                    
                    let response = self.defaultSession.sendSynchronousDataTaskWith(request: &urlRequest)
                    self.callCompletionHandlersFor(request: urlRequest, data: response.data, response: response.response, error: response.error)
                    RequestController.hideApplicationActivityIndicator()
                    
                } else {
                    
                    let dataTask = self.defaultSession.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
                        RequestController.hideApplicationActivityIndicator()
                        guard let self = self else { return }
                        self.callCompletionHandlersFor(request: urlRequest, data: data, response: response, error: error)
                    })
                    
                    dataTask.tag = request.tag
                    dataTask.resume()
                }
                
            } catch let error {
                
                completion?(nil, error)
            }
        }
    }
    
    //MARK: Upload
    
    /// Schedules a `Request` object to be uploaded using the `URLSession`.
    ///
    /// - Parameters:
    ///   - request: The request to be uploaded.
    ///   - date: When to make the request (defaults to current date).
    ///   - fileURL: The file url to upload from.
    ///   - progress: A closure to be called with progress updates.
    ///   - completion: A closure to be called once the upload has finished.
    public func scheduleUpload(_ request: Request, on date: Date? = nil, fileURL: URL?, progress: ProgressHandler?, completion: TransferCompletion?) {
        
        // Set activity indicator (Only if we're the first request)
        RequestController.showApplicationActivityIndicator()
        
        if let userAgent = UserDefaults.standard.string(forKey: "TSCUserAgent"), !request.headers.keys.contains("User-Agent") {
            request.headers["User-Agent"] = userAgent
        }
        
        checkOAuthStatusFor(request: request) { [weak self] (authenticated, error, needsQueueing) in
            
            if error != nil || !authenticated {
                
                RequestController.hideApplicationActivityIndicator()
                completion?(nil, nil, error)
                return
            }
            
            guard let self = self else { return }
            
            do {
                
                var urlRequest = try request.construct()
                
                if self.runSynchronously {
                    
                    let response: (data: Data?, response: URLResponse?, error: Error?)
                    if let body = urlRequest.httpBody {
                        response = self.defaultSession.sendSynchronousUploadTaskWith(request: &urlRequest, uploadData: body)
                    } else if let fileURL = fileURL {
                        response = self.defaultSession.sendSynchronousUploadTaskWith(request: &urlRequest, fileURL: fileURL)
                    } else {
                        //TODO: Throw error?
                        response = self.defaultSession.sendSynchronousUploadTaskWith(request: &urlRequest, uploadData: Data())
                    }
                    
                    RequestController.hideApplicationActivityIndicator()
                    var returnResponse: RequestResponse?
                    if let requestResponse = response.response {
                        returnResponse = RequestResponse(response: requestResponse, data: response.data)
                    }
                    completion?(returnResponse, nil, error)
                    
                } else {
                    
                    let task: URLSessionUploadTask
                    if let body = urlRequest.httpBody {
                        task = self.defaultSession.uploadTask(with: urlRequest.backgroundable ?? urlRequest, from: body)
                    } else if let fileURL = fileURL {
                        task = self.backgroundSession.uploadTask(with: urlRequest.backgroundable ?? urlRequest, fromFile: fileURL)
                    } else {
                        //TODO: Throw error?
                        task = self.backgroundSession.uploadTask(with: urlRequest.backgroundable ?? urlRequest, from: Data())
                    }
                    
                    if #available(iOS 11, watchOS 4.0, macOS 10.13, *) {
                        task.earliestBeginDate = date
                    }
                    
                    self.add(completionHandler: completion, progressHandler: progress, forTaskId: task.taskIdentifier)
                    
                    task.tag = request.tag
                    task.resume()
                }
                
            } catch let error {
                
                completion?(nil, nil, error)
            }
        }
    }
    
    //MARK: Download
    
    /// Schedules a `Request` object to be downloaded using the `URLSession`.
    ///
    /// - Parameters:
    ///   - request: The request to be downloaded.
    ///   - date: When to make the request (defaults to current date).
    ///   - progress: A closure to be called with progress updates.
    ///   - completion: A closure to be called once the download has finished.
    public func scheduleDownload(_ request: Request, on date: Date? = nil, progress: ProgressHandler?, completion: TransferCompletion?) {
        
        // Set activity indicator (Only if we're the first request)
        RequestController.showApplicationActivityIndicator()
        
        if let userAgent = UserDefaults.standard.string(forKey: "TSCUserAgent"), !request.headers.keys.contains("User-Agent") {
            request.headers["User-Agent"] = userAgent
        }
        
        checkOAuthStatusFor(request: request) { [weak self] (authenticated, error, needsQueueing) in
            
            if error != nil || !authenticated {
                
                RequestController.hideApplicationActivityIndicator()
                completion?(nil, nil, error)
                return
            }
            
            guard let self = self else { return }
            
            do {
                
                var urlRequest = try request.construct()
                
                if self.runSynchronously {
                    
                    let response = self.backgroundSession.sendSynchronousDownloadTaskWith(request: &urlRequest)
                    
                    RequestController.hideApplicationActivityIndicator()
                    var returnResponse: RequestResponse?
                    if let requestResponse = response.response {
                        returnResponse = RequestResponse(response: requestResponse, data: nil)
                    }
                    completion?(returnResponse, response.downloadURL, error)
                    
                } else {
                    
                    let backgroundableRequest = urlRequest.backgroundable ?? urlRequest
                    let task = self.backgroundSession.downloadTask(with: backgroundableRequest)
                    
                    if #available(iOS 11, watchOS 4.0, macOS 10.13, *) {
                        task.earliestBeginDate = date
                    }
                    
                    self.add(completionHandler: completion, progressHandler: progress, forTaskId: task.taskIdentifier)
                    
                    task.tag = request.tag
                    task.resume()
                }
                
            } catch let error {
                
                completion?(nil, nil, error)
            }
        }
    }
    
    //MARK: - Cancelling Requests -
    
    /// Cancels all requests in any of the queues, calling the completion
    /// block with a cancellation error
    public func cancelAllRequests() {
        defaultSession.invalidateAndCancel()
        backgroundSession.invalidateAndCancel()
        ephemeralSession.invalidateAndCancel()
        resetSessions()
    }
    
    /// Cancels requests with a specific tag in any of the request queues,
    /// calling the completion with a cancellation error
    ///
    /// - Parameter tag: The tag to cancel the requests for
    public func cancelRequestsWith(tag: Int) {
        
        defaultSession.getAllTasks { (tasks) in
            tasks.filter({ $0.tag == tag }).forEach({ (task) in
                task.cancel()
            })
        }
        
        backgroundSession.getAllTasks { (tasks) in
            tasks.filter({ $0.tag == tag }).forEach({ (task) in
                task.cancel()
            })
        }
        
        ephemeralSession.getAllTasks { (tasks) in
            tasks.filter({ $0.tag == tag }).forEach({ (task) in
                task.cancel()
            })
        }
    }
    
    /// Calls invalidateAndCancel on all internal `URLSession` objects
    /// to allow self to be deallocated
    public func invalidateAndCancel() {
        defaultSession.invalidateAndCancel()
        backgroundSession.invalidateAndCancel()
        ephemeralSession.invalidateAndCancel()
    }
    
    /// Sets the shared request credentials, optionally saving them to the keychain.
    ///
    /// - Parameters:
    ///   - sharedRequestCredentials: The request credential to set/save.
    ///   - savingToKeychain: Whether or not to save the credentials to the keychain.
    ///
    /// - Note: If a `OAuth2Credential` object is stored to the keychain by this method
    /// it will be fetched from the keychain each time an `OAuth2Delegate` with the same
    /// service identifier is set on the request controller. If `OAuth2Delegate` is non-nil
    /// when this method is called it will be saved under the current delegate's service
    /// identifier. Otherwise it will be saved under a string appended by `sharedBaseURL`
    public func set(sharedRequestCredentials: TSCRequestCredential, savingToKeychain: Bool) {
        
    }
}

extension RequestController {
    
    fileprivate static func showApplicationActivityIndicator() {
        #if os(iOS)
        if let option = Bundle.main.object(forInfoDictionaryKey: "TSCThunderRequestShouldHideActivityIndicator") as? Bool, !option {
            return
        }
        ApplicationLoadingIndicatorManager.shared.showActivityIndicator()
        #endif
    }
    
    fileprivate static func hideApplicationActivityIndicator() {
        #if os(iOS)
        if let option = Bundle.main.object(forInfoDictionaryKey: "TSCThunderRequestShouldHideActivityIndicator") as? Bool, !option {
            return
        }
        ApplicationLoadingIndicatorManager.shared.hideActivityIndicator()
        #endif
    }
}
