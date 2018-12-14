//
//  OAuth2Credential.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

@objc(TSCOauth2Credential)
public class OAuth2Credential: RequestCredential {
    
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
        super.init(authorizationToken: authorizationToken)
        self.tokenType = tokenType
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard let expirationDate = aDecoder.decodeObject(forKey: "TSCExpirationDate") as? Date else {
            return nil
        }
        guard let tokenType = aDecoder.decodeObject(forKey: "TSCTokenType") as? String else {
            return nil
        }
        
        self.expirationDate = expirationDate
        
        super.init(coder: aDecoder)
        
        self.tokenType = tokenType
        
        authorizationToken
         = aDecoder.decodeObject(forKey: "TSCAuthToken") as? String
        refreshToken = aDecoder.decodeObject(forKey: "TSCRefreshToken") as? String
    }
}
