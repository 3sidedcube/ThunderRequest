//
//  CredentialStore.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 18/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A protocol the underlying store used in `CredentialStore`
public protocol DataStore {
    
    func add(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool
    
    func update(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool
    
    func retrieveDataFor(identifier: String) -> Data?
    
    func removeDataFor(identifier: String) -> Bool
}

public struct KeychainStore: DataStore {
    
    private func keychainQueryWith(identifier: String, accessibility: CredentialStore.Accessibility? = nil) -> [AnyHashable : Any] {
        
        var dictionary: [CFString : Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: kTSCAuthServiceName,
            kSecAttrAccount: identifier,
        ]
        if let accessibility = accessibility {
            dictionary[kSecAttrAccessible] = accessibility.cfString
        }
        return dictionary
    }
    
    public func add(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        
        var query = keychainQueryWith(identifier: identifier, accessibility: accessibility)
        query[kSecValueData] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func update(data: Data, identifier: String, accessibility: CredentialStore.Accessibility) -> Bool {
        
        let query = keychainQueryWith(identifier: identifier, accessibility: accessibility)
        
        let updateDictionary = [
            kSecValueData: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
        
        return status == errSecSuccess
    }
    
    public func retrieveDataFor(identifier: String) -> Data? {
        
        var query = keychainQueryWith(identifier: identifier)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    public func removeDataFor(identifier: String) -> Bool {
        let result = SecItemDelete(keychainQueryWith(identifier: identifier) as CFDictionary)
        return result == errSecSuccess
    }
    
    public let serviceIdentifier: String
    
    public init(serviceName: String) {
        self.serviceIdentifier = serviceName
    }
}

public struct CredentialStore {
    
    /// An enum representation of CFString constants for the accessibility of keychain items
    ///
    /// - afterFirstUnlock: After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Migrates to new devices.
    /// - always: The data in the keychain item can always be accessed regardless of whether the device is locked. Migrates to new devices.
    /// - whenUnlocked: The data in the keychain item can be accessed only while the device is unlocked by the user. Migrates to new devices.
    /// - whenPasscodeSetThisDeviceOnly: The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device. Does not migrate to new devices.
    /// - whenUnlockedThisDeviceOnly: The data in the keychain item can be accessed only while the device is unlocked by the user. Does not migrate to new devices.
    /// - afterFirstUnlockThisDeviceOnly: The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user. Does not migrate to new devices.
    /// - alwaysThisDeviceOnly: The data in the keychain item can always be accessed regardless of whether the device is locked. Does not migrate to new devices.
    public enum Accessibility {
        
        case afterFirstUnlock
        case always
        case whenUnlocked
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
        case alwaysThisDeviceOnly
        
        var cfString: CFString {
            switch self {
            case .afterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
            case .always:
                return kSecAttrAccessibleAlways
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .alwaysThisDeviceOnly:
                return kSecAttrAccessibleAlwaysThisDeviceOnly
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            }
        }
    }
    
    /// Stores the credential in the keychain under a certian identifier
    ///
    /// - Parameters:
    ///   - credential: The credentials object to store in the keychain
    ///   - identifier: The identifier to store the credential object under
    ///   - accessibility: The access rule for the credential
    /// - Returns: Whether the item was sucessfully stored
    @discardableResult public static func store(credential: RequestCredential?, identifier: String, accessibility: Accessibility = .afterFirstUnlock, in store: DataStore = KeychainStore(serviceName: kTSCAuthServiceName)) -> Bool {
        
        guard let credential = credential else {
            return delete(withIdentifier: identifier)
        }
        
        let existingCredential = retrieve(withIdentifier: identifier)
        let exists = existingCredential != nil
        
        if exists {
            return store.update(data: credential.keychainData, identifier: identifier, accessibility: accessibility)
        } else {
            return store.add(data: credential.keychainData, identifier: identifier, accessibility: accessibility)
        }
    }
    
    /// Deletes an entry for a certain identifier from the keychain
    ///
    /// - Parameter withIdentifier: The identifier to delete the credential object for
    /// - Returns: The retrieved credential
    /// - Throws: An error if retrieval fails
    public static func retrieve(withIdentifier identifier: String, from store: DataStore = KeychainStore(serviceName: kTSCAuthServiceName)) -> RequestCredential? {
        
        guard let data = store.retrieveDataFor(identifier: identifier) else {
            return nil
        }
        
        return RequestCredential.init(keychainData: data)
    }
    
    /// Deletes an entry for a certain identifier from the keychain
    ///
    /// - Parameter withIdentifier: The identifier to delete the credential object for
    /// - Returns: Whether the item was sucessfully deleted
    @discardableResult public static func delete(withIdentifier identifier: String, in store: DataStore = KeychainStore(serviceName: kTSCAuthServiceName)) -> Bool {
        return store.removeDataFor(identifier: identifier)
    }
}
