//
//  DownloadTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import XCTest
@testable import ThunderRequest

class UploadTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://httpbin.org/")!
    
    func testUploadFromURLSucceeds() {
        
        guard let fileURL = Bundle(for: UploadTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Didn't get filepath for test image")
        }
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let finishExpectation = expectation(description: "App should correctly upload file to server")

        requestController.uploadFile(fileURL, to: "post", progress: { (progress, _, _) in
            
            XCTAssertTrue(progress >= 0.0 && progress <= 1.0)
            
        }) { (response, url, error) in
            
            finishExpectation.fulfill()
        }
    }
}
