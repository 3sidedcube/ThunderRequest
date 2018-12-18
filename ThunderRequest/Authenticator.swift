//
//  Authenticator.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// Authenticator is a protocol which is used by `RequestController` to generate and re-authenticate credential objects
///
/// To perform the initial authentication call your own `authenticateWithCompletion` implementation
/// and then save the credential object which you would otherwise return
/// in the completion block to the keychain using `RequestCredential.store(credential:withIdentifier)`.
/// Once you have stored the credential in the keychain all requests will check that it hasn't expired
/// before making the request.
///
/// Setting the `RequestController`'s `sharedRequestCredential` using `set(sharedRequestCredentials:savingToKeychain:)`
/// with savingToKeychain as true will also achieve the same affect.
public protocol Authenticator {
    
    /// This method will be called if a request is made without a `RequestCredential` object having
    /// been saved to the keychain under `authIdentifier`
    ///
    /// - Parameter completion: The closure which must be called when the user has been authenticated
    func authenticate<T: Credential>(completion: (_ credential: T?, _ error: Error?, _ saveToKeychain: Bool) -> Void)
    
    /// The data store which should be used to store and retrieve credential objects
    /// Defaults to an instance of KeychainStore
    var dataStore: DataStore { get }
    
    /// This defines the service identifier for the auth flow, which the credentials object will
    /// be saved under in the user's keychain
    var authIdentifier: String { get }
    
    /// The accessibility level of the credential when stored in the user's keychain
    var keychainAccessibility: CredentialStore.Accessibility { get }
    
    /// This method will be called if a request is made with an expired token, or if we recieve a 403 challenge from a particular request
    ///
    /// - Parameters:
    ///   - credential: The credential which should be used in the refresh process
    ///   - completion: The completion block which should be called when the user's credential has been refreshed
    func reAuthenticate<T: Credential>(credential: T?, completion: (_ credential: T?, _ error: Error?, _ saveToKeychain: Bool) -> Void)
}

extension Authenticator {
    var dataStore: DataStore {
        return KeychainStore(serviceName: kTSCAuthServiceName)
    }
}
