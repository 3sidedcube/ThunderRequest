//
//  RequestCredential.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

public let kTSCAuthServiceName = "TSCAuthCredential"

/// A protocol which can be implemented to provide authentication for HTTP requests
public protocol Credential {
    
    /// Returns the url credential which can be used to authenticate a request
    var credential: URLCredential? { get }
    
    /// The username to auth the user with
    var username: String? { get }
    
    /// The password to auth the user with
    var password: String? { get }
    
    /// The auth token to auth the user with
    var authorizationToken: String? { get }
    
    /// The type of the token
    var tokenType: String { get }
    
    /// The data to store in the keychain
    var keychainData: Data { get }
    
    /// Init method for re-constructing from data stored in the user's keychain
    ///
    /// - Parameter keychainData: The data which was retrieved from the keychain
    init?(keychainData: Data)
    
    /// Whether the credential has expired
    var hasExpired: Bool { get }
}

private class _AnyCredentialBase: Credential {
    
    var credential: URLCredential? {
        get { fatalError("Must override") }
    }
    
    var username: String? {
        get { fatalError("Must override") }
    }
    
    var password: String? {
        get { fatalError("Must override") }
    }
    
    var authorizationToken: String? {
        get { fatalError("Must override") }
    }
    
    var tokenType: String {
        get { fatalError("Must override") }
    }
    
    var keychainData: Data {
        get { fatalError("Must override") }
    }
    
    required init?(keychainData: Data) {
        fatalError("Must override")
    }
    
    var hasExpired: Bool {
        get { fatalError("Must override") }
    }
    
    // Let's make sure that init() cannot be called to initialise this class.
    init() {
        guard type(of: self) != _AnyCredentialBase.self else {
            fatalError("Cannot initialise, must subclass")
        }
    }
}

private final class _AnyCredentialBox<ConcreteCredential: Credential>: _AnyCredentialBase {
    
    // Store the concrete type
    var concrete: ConcreteCredential
    
    // Define init()
    init(_ concrete: ConcreteCredential) {
        self.concrete = concrete
        super.init()
    }
    
    required init?(keychainData: Data) {
        fatalError("init(keychainData:) has not been implemented")
    }
}

public final class AnyCredential: Credential {
    
    public var credential: URLCredential? {
        return box.credential
    }
    
    public var username: String? {
        return box.username
    }
    
    public var password: String? {
        return box.password
    }
    
    public var authorizationToken: String? {
        return box.authorizationToken
    }
    
    public var tokenType: String {
        return box.tokenType
    }
    
    public var keychainData: Data {
        return box.keychainData
    }
    
    public init?(keychainData: Data) {
        guard let _box = _AnyCredentialBase(keychainData: keychainData) else {
            return nil
        }
        box = _box
    }
    
    public var hasExpired: Bool {
        return box.hasExpired
    }
    
    // Store the box specialised by content.
    // This line is the reason why we need an abstract class _AnyCredentialBase. We cannot store here an instance of _AnyCredentialBox directly because the concrete type for Cup is provided by the initialiser, at a later stage.
    private let box: _AnyCredentialBase
    
    // Initialise the class with a concrete type of Cup where the content is restricted to be the same as the genric paramenter
    init<Concrete: Credential>(_ concrete: Concrete) {
        box = _AnyCredentialBox(concrete)
    }
}

/// A request credential is anything that can be used to authorize a HTTP request
@objc (TSCRequestCredential)
public class RequestCredential: NSObject, NSCoding, Credential {
    
    public var hasExpired: Bool {
        return false
    }
    
    public var keychainData: Data {
        return NSKeyedArchiver.archivedData(withRootObject:self)
    }
    
    public required init?(keychainData: Data) {
        guard let credential = NSKeyedUnarchiver.unarchiveObject(with: keychainData) as? RequestCredential else {
            return nil
        }
        self.authorizationToken = credential.authorizationToken
        self.credential = credential.credential
        self.username = credential.username
        self.password = credential.password
        self.tokenType = credential.tokenType
    }
    
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
