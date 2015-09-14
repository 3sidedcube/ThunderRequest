//
//  ThunderRequest-KeychainTests.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

import XCTest
import ThunderRequest

class ThunderRequest_KeychainTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialiseUsernamePasswordCredential() {
        
        let credential = TSCRequestCredential(username: "test", password: "123")
        
        XCTAssertNotNil(credential.username, "Username is nil")
        XCTAssertNotNil(credential.password, "Password is nil")
        XCTAssertNotNil(credential.credential, "Credential is nil")
    }
    
    func testInitialiseAuthTokenCredential() {
        
        let credential = TSCRequestCredential(authorizationToken: "SHADSJMAS")
        
        XCTAssertNotNil(credential.authorizationToken, "Authorization Token is nil")
    }
    
    func testInitialiseOAuth2Credential() {
        
        let credential = TSCOAuth2Credential(authorizationToken: "saDHSAHF", refreshToken: "DSAHJDSA", expiryDate: NSDate(timeIntervalSinceNow: 24))
        
        XCTAssertNotNil(credential.authorizationToken, "Authorization Token is nil")
        XCTAssertNotNil(credential.refreshToken, "Refresh Token is nil")
        XCTAssertNotNil(credential.expirationDate, "Expiry Date is nil")
    }
    
    func testPasswordUsernameCredentialToKeychain() {
        
        let credential = TSCRequestCredential(username: "test", password: "123")
        
        TSCRequestCredential.storeCredential(credential, withIdentifier: "credential")
        
        let pulledCredential = TSCRequestCredential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNotNil(pulledCredential, "Credential was not saved or pulled from keychain")
        XCTAssertNotNil(pulledCredential.username, "Credential username was retrieved as nil")
        XCTAssertNotNil(pulledCredential.password, "Credential password was retrieved as nil")
        XCTAssertNotNil(pulledCredential.credential, "Credential credential was retrieved as nil")
        
        TSCRequestCredential.deleteCredentialWithIdentifier("credential")
        
        let deletedCredential = TSCRequestCredential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNil(deletedCredential, "Credential was not deleted correctly from the keychain")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testAuthTokenCredentialToKeychain() {
        
        let credential = TSCRequestCredential(authorizationToken: "TOKEN")
        
        TSCRequestCredential.storeCredential(credential, withIdentifier: "credential")
        
        let pulledCredential = TSCRequestCredential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNotNil(pulledCredential, "Credential was not saved or pulled from keychain")
        XCTAssertNotNil(pulledCredential.authorizationToken, "Credential token was retrieved as nil")
        
        TSCRequestCredential.deleteCredentialWithIdentifier("credential")
        
        let deletedCredential = TSCRequestCredential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNil(deletedCredential, "Credential was not deleted correctly from the keychain")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testOAuth2CredentialToKeychain() {
        
        let credential = TSCOAuth2Credential(authorizationToken: "TOKEN", refreshToken: "REFRESHTOKEN", expiryDate: NSDate(timeIntervalSinceNow: 24))
        
        TSCOAuth2Credential.storeCredential(credential, withIdentifier: "credential")
        
        let pulledCredential = TSCOAuth2Credential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNotNil(pulledCredential, "Credential was not saved or pulled from keychain")
        XCTAssertNotNil(pulledCredential.authorizationToken, "Credential token was retrieved as nil")
        XCTAssertNotNil(pulledCredential.refreshToken, "Credential refresh token was retrieved as nil")
        XCTAssertNotNil(pulledCredential.expirationDate, "Credential expiry date was retrieved as nil")
        
        TSCRequestCredential.deleteCredentialWithIdentifier("credential")
        
        let deletedCredential = TSCRequestCredential.retrieveCredentialWithIdentifier("credential")
        
        XCTAssertNil(deletedCredential, "Credential was not deleted correctly from the keychain")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
}
