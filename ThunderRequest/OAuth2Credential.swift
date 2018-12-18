//
//  OAuth2Credential.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public class OAuth2Credential: NSObject, NSCoding, Credential {
    
    public var credential: URLCredential?
    
    public var username: String?
    
    public var password: String?
    
    public var authorizationToken: String?
    
    public var tokenType: String
    
    public var keychainData: Data {
        return NSKeyedArchiver.archivedData(withRootObject:self)
    }
    
    /// The date on which the authorization token expires
    public var expirationDate: Date
    
    /// The refresh token to be sent back to the authenticating endpoint for certain auth methods
    public var refreshToken: String?
    
    /// Returns whether the credential has expired
    public var hasExpired: Bool {
        return Date() > expirationDate
    }
    
    /// Initialises a new OAuth2 credential with given parameters
    ///
    /// - Parameters:
    ///   - authorizationToken: The authorizationToken to be sent by `RequestController` for authentication requests.
    ///   - refreshToken: The refresh token to be sent back to the authenticating endpoint for certain authentification methods.
    ///   - expiryDate: The date upon which the credential will expire for the user.
    ///   - tokenType: The token type of the credential (Defaults to Bearer)
    public init(authorizationToken: String, refreshToken: String?, expiryDate: Date, tokenType: String = "Bearer") {
        
        self.refreshToken = refreshToken
        self.expirationDate = expiryDate
        self.authorizationToken = authorizationToken
        self.tokenType = tokenType
        super.init()
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(authorizationToken, forKey: "authtoken")
        aCoder.encode(credential, forKey: "credential")
        aCoder.encode(tokenType, forKey: "tokentype")
        aCoder.encode(expirationDate, forKey: "expiration")
        aCoder.encode(refreshToken, forKey: "refreshtoken")
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        
        guard let expiry = aDecoder.decodeObject(forKey: "expiration") as? Date else {
            return nil
        }
        
        tokenType = aDecoder.decodeObject(forKey: "tokentype") as? String ?? "Bearer"
        username = aDecoder.decodeObject(forKey: "username") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
        authorizationToken = aDecoder.decodeObject(forKey: "authtoken") as? String
        credential = aDecoder.decodeObject(forKey: "credential") as? URLCredential
        refreshToken = aDecoder.decodeObject(forKey: "refreshtoken") as? String
        expirationDate = expiry
        super.init()
    }
    
    public required init?(keychainData: Data) {
        guard let credential = NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? OAuth2Credential else {
            return nil
        }
        self.expirationDate = credential.expirationDate
        self.authorizationToken = credential.authorizationToken
        self.credential = credential.credential
        self.username = credential.username
        self.password = credential.password
        self.tokenType = credential.tokenType
        self.refreshToken = credential.refreshToken
    }
}
