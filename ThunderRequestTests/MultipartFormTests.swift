//
//  MultipartFormTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 17/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
import Foundation
@testable import ThunderRequest

class MultipartFormTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringElementFormatsCorrectly() {
        
        let stringElement = "Hello World"
        let multipartData = stringElement.multipartDataWith(boundary: "123456", key: "sentence")
        XCTAssertEqual(multipartData?.count, 70)
        XCTAssertNotNil(multipartData)
        guard let data = multipartData else {
            return
        }
        XCTAssertEqual(String(data: data, encoding: .utf8), "--123456\r\nContent-Disposition: form-   ;name=\"sentence\"\r\nHello World\r\n")
    }
    
    func testImageFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imageMultiPartData = image.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 8204)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...144], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data; name=\"image\"; filename=\"filename.jpg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[8193...8203], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[145...8192])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, CGSize(width: 350, height: 150))
    }
    
    func testFileElementFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let fileData = try? Data(contentsOf: imageURL) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imagePart = MultipartFormFile(
            fileData: fileData,
            contentType: "image/png",
            fileName: "fileface.png",
            disposition: "form-data",
            name: "hello",
            transferEncoding: "bubbles"
        )
        let imageMultiPartData = imagePart.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 1408)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...143], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data;name=\"hello\"; filename=\"fileface.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: bubbles\r\n\r\n")
        XCTAssertEqual(String(data: data[1397...1407], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[144...1407])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, CGSize(width: 350, height: 150))
    }
    
    func testFileElementWithDefaultsFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let fileData = try? Data(contentsOf: imageURL) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imagePart = MultipartFormFile(
            fileData: fileData,
            contentType: "image/png",
            fileName: "fileface.png"
        )
        let imageMultiPartData = imagePart.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 1407)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...142], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data;name=\"image\"; filename=\"fileface.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[1396...1406], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[143...1406])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, CGSize(width: 350, height: 150))
    }
    
    func testJpegFileFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imageFile = MultipartFormFile(image: image, format: .jpeg, fileName: "image.jpg", name: "image")
        XCTAssertNotNil(imageFile)
        
        let imageMultiPartData = imageFile?.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 8200)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...140], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data;name=\"image\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[8189...8199], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[141...8188])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, CGSize(width: 350, height: 150))
    }
    
    func testPNGFileFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let imageFile = MultipartFormFile(image: image, format: .png, fileName: "image.png", name: "image")
        XCTAssertNotNil(imageFile)
        
        let imageMultiPartData = imageFile?.multipartDataWith(boundary: "ABCDEFG", key: "image")
        
        XCTAssertNotNil(imageMultiPartData)
        XCTAssertEqual(imageMultiPartData?.count, 1941)
        
        guard let data = imageMultiPartData else { return }
        XCTAssertEqual(String(data: data[0...139], encoding: .utf8), "--ABCDEFG\r\nContent-Disposition: form-data;name=\"image\"; filename=\"image.png\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n")
        XCTAssertEqual(String(data: data[1930...1940], encoding: .utf8), "\r\n--ABCDEFG")
        
        let dataImage = UIImage(data: data[140...1931])
        XCTAssertNotNil(dataImage)
        XCTAssertEqual(dataImage?.size, CGSize(width: 350, height: 150))
    }
    
    func testWholeFormFormatsCorrectly() {
        
        guard let imageURL = Bundle(for: MultipartFormTests.self).url(forResource: "350x150", withExtension: "png") else {
            fatalError("Couldn't find test image file")
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            fatalError("Couldn't create image from test image file")
        }
        
        let pngFile = MultipartFormFile(image: image, format: .png, fileName: "image.png", name: "image")!
        let jpegFile = MultipartFormFile(image: image, format: .jpeg, fileName: "image.jpeg", name: "jpeg")!
        
        let formBody = MultipartFormRequestBody(
            parts: [
                "png": pngFile,
                "jpeg": jpegFile
            ],
            boundary: "ABCDEFG"
        )
        
        let payload = formBody.payload()
        
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload?.count, 10141)
        XCTAssertEqual(formBody.contentType, "multipart/form-data; boundary=ABCDEFG")
    }
}
