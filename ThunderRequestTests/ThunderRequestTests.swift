//
//  ThunderRequestTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

import UIKit
import XCTest
import ThunderRequest

class ThunderRequestTests: XCTestCase {
    
    let requestBaseURL = NSURL(string: "https://httpbin.org/")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateControllerWithURL() {
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        XCTAssertNotNil(requestController, "A request Controller failed to be initialised with a URL")
    }
    
    func testRequestInvokesSuccessCompletionBlockWithResponseObject() {
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("GET Request")
        
        requestController.get("get") { (response, error) -> Void in
            
            XCTAssertNil(error, "Request controller returned error for GET request")
            XCTAssertNotNil(response, "Request Controller did not return a resposne object")
            
            finishExpectation.fulfill()
            
        }
        
        waitForExpectationsWithTimeout(35) { (error) -> Void in
            
            XCTAssertNil(error, "The GET request timed out")
            
        }
        
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn404() {
            
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("404 Request should return with response and error")
        
        requestController.get("status/404", completion: { (response, error) -> Void in

            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response!.status, 404, "Request controller did not return 404")
            
            finishExpectation.fulfill()
            
        })
        
        waitForExpectationsWithTimeout(35, handler: { (error) -> Void in
            
            XCTAssertNil(error, "The 404 request timed out")
            
        })
        
    }
    
    func testOperationInvokesFailureCompletionBlockWithErrorOn500() {
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("500 Response should return with response and error")
        
        requestController.get("status/500", completion: { (response, error) -> Void in
            
            XCTAssertNotNil(error, "Request controller did not return an error object")
            XCTAssertNotNil(response, "Request controller did not return a response object")
            XCTAssertEqual(response!.status, 500, "Request controller did not return 500")
            
            finishExpectation.fulfill()
            
        })
        
        waitForExpectationsWithTimeout(35, handler: { (error) -> Void in
            
            XCTAssertNil(error, "The 404 request timed out")
            
        })
    }
    
    func testAppIsNotifiedAboutServerErrors() {
    
        let requestController = TSCRequestController(baseURL: requestBaseURL!)

        let finishExpectation = expectationWithDescription("App should be notified about server errors")

        var notificationFound = false

        let observer = NSNotificationCenter.defaultCenter().addObserverForName("TSCRequestServerError", object: nil, queue: nil) { (notification) -> Void in

            notificationFound = true

        }

        requestController.get("status/500", completion: { (response, error) -> Void in

            if notificationFound == true {
                finishExpectation.fulfill()
            }

        })
    
        waitForExpectationsWithTimeout(35, handler: { (error) -> Void in

            XCTAssertNil(error, "The notification test timed out")
            
            NSNotificationCenter.defaultCenter().removeObserver(observer)

        })
    }
    
    func testAppIsNotifiedAboutServerResponse() {
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("App should be notified about server responses")
        
        var notificationFound = false
        
        let observer = NSNotificationCenter.defaultCenter().addObserverForName("TSCRequestDidReceiveResponse", object: nil, queue: nil) { (notification) -> Void in
            
            notificationFound = true
            
        }
        
        requestController.get("status/500", completion: { (response, error) -> Void in
            
            if notificationFound == true {
                finishExpectation.fulfill()
            }
            
        })
        
        waitForExpectationsWithTimeout(35, handler: { (error) -> Void in
            
            XCTAssertNil(error, "The server response notification test timed out")
            
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            
        })
    }
    
    func testPostRequest() {
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("App should correctly send POST data to server")
        
        requestController.post("post", bodyParams: [NSString(string: "RequestTest"):"Success"], completion: { (response: TSCRequestResponse?, error: NSError?) -> Void in
            
            let responseJson = response?.dictionary?["json"] as! Dictionary<String, String>
            let successString = responseJson["RequestTest"]
            XCTAssertTrue(successString == "Success", "Server did not return POST body sent by request kit")
            finishExpectation.fulfill()
            
        })
        
        waitForExpectationsWithTimeout(35, handler: { (error) -> Void in
        
            XCTAssertNil(error, "The POST request timed out")
            
        })
    }
    
}
