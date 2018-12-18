//
//  AuthTests.swift
//  ThunderRequestTests
//
//  Created by Simon Mitchell on 18/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import XCTest
@testable import ThunderRequest

class DummyAuthenticator: Authenticator {
    
    func authenticate<T>(completion: (T?, Error?, Bool) -> Void) where T : Credential {
        
    }
    
    var keychainAccessibility: CredentialStore.Accessibility {
        return .always
    }
    
    func reAuthenticate<T>(credential: T?, completion: (T?, Error?, Bool) -> Void) where T : Credential {
        
    }
    
    var authIdentifier: String = "dummyauthenticator"
    
    var dataStore: DataStore
    
    init(store: DataStore) {
        self.dataStore = store
    }
}

class KeychainMockStore: DataStore {
    
    var internalStore: [String : Data] = [:]
    
    init() {
        
    }
    
    func add(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        internalStore[identifier] = data
        return true
    }
    
    func update(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        internalStore[identifier] = data
        return true
    }
    
    func retrieveDataFor(identifier: String) -> Data? {
        return internalStore[identifier]
    }
    
    func removeDataFor(identifier: String) -> Bool {
        guard internalStore[identifier] != nil else {
            return false
        }
        internalStore[identifier] = nil
        return true
    }
}

class AuthTests: XCTestCase {
    
    let requestBaseURL = URL(string: "https://httpbin.org/")!

    func testFetchesAuthWhenAuthenticatorSet() {
        
        let requestController = RequestController(baseURL: requestBaseURL)
        
        let credential = OAuth2Credential(authorizationToken: "token", refreshToken: "refresh", expiryDate: Date(timeIntervalSinceNow: 1600))
        
        let store = KeychainMockStore()
        
        CredentialStore.store(credential: credential, identifier: "dummyauthenticator", accessibility: .always, in: store)
        
        let authenticator = DummyAuthenticator(store: store)
        
        requestController.authenticator = authenticator
        
        XCTAssertNotNil(requestController.sharedRequestCredentials)
        XCTAssertEqual(requestController.sharedRequestCredentials?.authorizationToken, "token")
        XCTAssertEqual(requestController.sharedRequestCredentials?.hasExpired, false)
    }

}
