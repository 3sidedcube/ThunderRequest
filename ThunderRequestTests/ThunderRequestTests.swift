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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateControllerWithURL() {
        
        let requestBaseURL = NSURL(string: "https://www.google.com")
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        XCTAssertNotNil(requestController, "A request Controller failed to be initialised with a URL")
    }
    
    func testGetRequest() {
        
        let requestBaseURL = NSURL(string: "https://www.google.com")
        
        let requestController = TSCRequestController(baseURL: requestBaseURL!)
        
        let finishExpectation = expectationWithDescription("Get completed")
        
        requestController.get("search") { (response, error) -> Void in
            
            XCTAssertNil(error, "Request controller returned error for GET request")
            XCTAssertNotNil(response, "Request Controller did not return a resposne object")
            
            finishExpectation.fulfill()
            
        }
        
        waitForExpectationsWithTimeout(35) { (error) -> Void in
            
            XCTAssertNil(error, "The GET request timed out")
            
        }
        
    }
    
}
