//
//  RequestCredential.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

let kTSCAuthServiceName = "TSCAuthCredential"

/// A request credential is anything that can be used to authorize a HTTP request
@objc (TSCRequestCredential)
public class RequestCredential: NSObject, NSCoding {
    
    /// Returns the url credential which can be used to authenticate a request
    public var credential: URLCredential?
    
    /// The username to auth the user with
    public var username: String?
    
    /// The password to auth the user with
    public var password: String?
    
    /// The auth token to auth the user with
    public var authorizationToken: String?
    
    /// The type of the token
    public var tokenType: String = "Bearer"
    
    /// Creates a new username/password based credential
    ///
    /// - Parameters:
    ///   - username: The username of the authorization object
    ///   - password: The password of the authorization object
    init(username: String, password: String) {
        super.init()
        credential = URLCredential(user: username, password: password, persistence: .none)
        self.username = username
        self.password = password
    }
    
    /// Creates a new auth token based credential
    ///
    /// - Parameter authorizationToken: The authorization token to use
    init(authorizationToken: String) {
        super.init()
        self.authorizationToken = authorizationToken
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(authorizationToken, forKey: "authtoken")
        aCoder.encode(credential, forKey: "credential")
        aCoder.encode(tokenType, forKey: "tokentype")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        username = aDecoder.decodeObject(forKey: "username") as? String
        password = aDecoder.decodeObject(forKey: "password") as? String
        authorizationToken = aDecoder.decodeObject(forKey: "authtoken") as? String
        credential = aDecoder.decodeObject(forKey: "credential") as? URLCredential
        tokenType = aDecoder.decodeObject(forKey: "tokentype") as? String ?? "Bearer"
    }
}

//MARK: - Keychain Access -
extension RequestCredential {
    
    static func keychainDictionaryWith(identifier: String) -> [AnyHashable : Any] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: kTSCAuthServiceName,
            kSecAttrAccount: identifier
        ]
    }
    
    /// Stores the credential in the keychain under a certian identifier
    ///
    /// - Parameters:
    ///   - credential: The credentials object to store in the keychain
    ///   - identifier: The identifier to store the credential object under
    /// - Returns: Whether the item was sucessfully stored
    @discardableResult public static func store(credential: RequestCredential?, identifier: String) -> Bool {
        
        guard let credential = credential else {
            return delete(withIdentifier: identifier)
        }
        
        var query = keychainDictionaryWith(identifier: identifier)
        
        let updateDictionary = [
            kSecValueData: NSKeyedArchiver.archivedData(withRootObject: credential)
        ]
        
        let exists = retrieve(withIdentifier: identifier) != nil
        let status: OSStatus
        
        if exists {
            status = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
        } else {
            query[kSecValueData] = updateDictionary[kSecValueData]
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        return status == errSecSuccess
    }
    
    /// Deletes an entry for a certain identifier from the keychain
    ///
    /// - Parameter withIdentifier: The identifier to delete the credential object for
    /// - Returns: The retrieved credential
    /// - Throws: An error if retrieval fails
    public static func retrieve(withIdentifier identifier: String) -> RequestCredential? {
        var query = keychainDictionaryWith(identifier: identifier)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        guard let data = result as? Data else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? RequestCredential
    }
    
    /// Deletes an entry for a certain identifier from the keychain
    ///
    /// - Parameter withIdentifier: The identifier to delete the credential object for
    /// - Returns: Whether the item was sucessfully deleted
    @discardableResult public static func delete(withIdentifier identifier: String) -> Bool {
        let result = SecItemDelete(keychainDictionaryWith(identifier: identifier) as CFDictionary)
        return result == errSecSuccess
    }
}
