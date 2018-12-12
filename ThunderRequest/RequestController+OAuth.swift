//
//  RequestController+OAuth.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 12/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

typealias OAuthCheckCompletion = (_ authenticated: Bool, _ error: Error?, _ needsQueueing: Bool) -> Void

extension RequestController {
    
    /// Checks the OAuth authentication status for a given request
    ///
    /// - Parameters:
    ///   - request: The request to check authentication for
    ///   - completion: Closure callback with result
    func checkOAuthStatusFor(request: Request, completion: @escaping OAuthCheckCompletion) {
        
        guard let oAuth2Delegate = oAuth2Delegate else {
            completion(true, nil, false)
            return
        }
        
        // If we have an oAuth2 delegate and the request isn't the request to refresh the token
        if sharedRequestCredentials as? TSCOAuth2Credential == nil {
            sharedRequestCredentials = TSCOAuth2Credential.retrieveCredential(withIdentifier: oAuth2Delegate.authIdentifier())
        }
        
        // Make sure we have shared credentials, and they are oAuth2 credentials
        guard let oAuth2Credentials = sharedRequestCredentials as? TSCOAuth2Credential else {
            completion(true, nil, false)
            return
        }
        
        guard !oAuth2Credentials.hasExpired, !self.reAuthenticating else {
            // If we are re-authenticating then the token has expired, but this is not the
            // request that will refresh it, then this request can be queued by the user
            completion(!self.reAuthenticating, nil, self.reAuthenticating)
            return
        }
        
        // Important so if the re-authenticating call uses this request controller
        // to make the authentication request, we don't end up in an infinite loop!
        self.reAuthenticating = true
        
        oAuth2Delegate.reAuthenticateCredential(oAuth2Credentials) { [weak self] (newCredential, error, saveToKeychain) in
            
            // If we don't have an error, then save the credentials to the keychain
            if let credentials = newCredential, error == nil {
                if saveToKeychain {
                    TSCOAuth2Credential.store(credentials, withIdentifier: oAuth2Delegate.authIdentifier())
                }
                self?.sharedRequestCredentials = credentials
            }
            
            // Call back to the initial OAuth check
            completion(error == nil, error, false)
            
            guard let self = self else { return }
            
            // Re-schedule any requests that were queued whilst we were refreshing the OAuth token
            self.requestsQueuedForAuthentication.forEach({ (request, completion) in
                self.schedule(request: request, completion: completion)
            })
            
            self.requestsQueuedForAuthentication = []
            self.reAuthenticating = false
        }
    }
}