//
//  ThunderRequestTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

import UIKit
import XCTest
@testable import ThunderRequest

class ThunderRequestTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://httpbin.org/")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateControllerWithURL() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        XCTAssertNotNil(requestController, "A request Controller failed to be initialised with a URL")
    }
    
    func testRequestInvokesSuccessCompletionBlockWithResponseObject() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "GET Request")
        
        requestController.request("get", method: .GET) { (response, error) in
            
            XCTAssertNil(error, "Request controller returned error for GET request")
            XCTAssertNotNil(response, "Request Controller did not return a response object")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35) { (error) -> Void in
            XCTAssertNil(error, "The GET request timed out")
        }
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn404() {
            
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "404 Request should return with response and error")
        
        requestController.request("status/404", method: .GET) { (response, error) in
            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response?.status, .notFound, "Request controller did not return 404")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The 404 request timed out")
        })
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn500() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "500 Response should return with response and error")
        
        requestController.request("status/500", method: .GET) { (response, error) in
            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response!.status, .internalServerError, "Request controller did not return 500")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The 404 request timed out")
        })
    }
    
    func testAppIsNotifiedAboutServerErrors() {
    
        let requestController = RequestController(baseURL: requestBaseURL)

        let finishExpectation = expectation(description: "App should be notified about server errors")

        var notificationFound = false

        let observer = NotificationCenter.default.addObserver(forName: RequestController.DidErrorNotificationName, object: nil, queue: nil) { (notification) -> Void in
            notificationFound = true
        }

        requestController.request("status/500", method: .GET) { (response, error) in
            if notificationFound == true {
                finishExpectation.fulfill()
            }
        }
    
        waitForExpectations(timeout: 35, handler: { (error) -> Void in

            XCTAssertNil(error, "The notification test timed out")
            NotificationCenter.default.removeObserver(observer)
        })
    }
    
    func testAppIsNotifiedAboutServerResponse() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should be notified about server responses")
        
        var notificationFound = false
        
        let observer = NotificationCenter.default.addObserver(forName: RequestController.DidReceiveResponseNotificationName, object: nil, queue: nil) { (notification) -> Void in
            
            notificationFound = true
            
        }
        
        requestController.request("status/500", method: .GET) { (response, error) in
            if notificationFound == true {
                finishExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            
            XCTAssertNil(error, "The server response notification test timed out")
            
            NotificationCenter.default.removeObserver(observer)
            
        })
    }
    
    func testPostRequest() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should correctly send POST data to server")
        
        requestController.request("post", method: .POST, body: JSONRequestBody(["RequestTest": "Success"])) { (response, error) in
            
            let responseJson = response?.dictionary?["json"] as! Dictionary<String, String>
            let successString = responseJson["RequestTest"]
            XCTAssertTrue(successString == "Success", "Server did not return POST body sent by request kit")
            finishExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The POST request timed out")
        })
    }
    
    func testCancelRequestWithTagReturnsCancelledError() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should correctly send POST data to server")
        
        requestController.request("get", method: .GET, tag: 123) { (_, error) in
            print("Error", error ?? "")
            finishExpectation.fulfill()
        }
        requestController.cancelRequestsWith(tag: 123)
        
        waitForExpectations(timeout: 35, handler: { (error) -> Void in
            XCTAssertNil(error, "The GET request timed out")
        })
    }
}
