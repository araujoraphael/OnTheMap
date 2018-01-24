//
//  SessionHandler.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-21.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import Foundation
import FBSDKLoginKit

enum SessionHandlerResult {
    case success
    case failure(Error)
}

struct SessionHandler {
    static func createSession(email: String, password: String, onCompletion: @escaping (SessionHandlerResult) -> Void) {
        var sessionHandlerResult: SessionHandlerResult!

        UdacityClient.createSessionRequest(email: email, password: password) { (result) in
            switch result {
            case let .success(session):
                SharedData.shared.session = session
                sessionHandlerResult = .success
                UdacityClient.studentDataRequest(userKey: session.userKey, onCompletion: { (result) in
                    switch result {
                    case let .success(sessionWithUserData):
                        if let firstName = sessionWithUserData.firstName {
                            SharedData.shared.session.firstName = firstName
                        }
                        if let lastName = sessionWithUserData.lastName {
                            SharedData.shared.session.lastName = lastName
                        }
                        onCompletion(sessionHandlerResult)
                        break
                    case let .failure(error):
                        onCompletion(.failure(error))
                        break
                    }
                })
                break
            case let .failure(error):
                sessionHandlerResult = .failure(error)
                onCompletion(sessionHandlerResult)
                break
            }
        }
    }
    
    static func createSession(facebookToken: String, onCompletion: @escaping (SessionHandlerResult) -> Void) {
        var sessionHandlerResult: SessionHandlerResult!
        
        UdacityClient.createSessionWithFacebookRequest(facebookToken: facebookToken) { (result) in
            switch result {
            case let .success(session):
                SharedData.shared.session = session
                sessionHandlerResult = .success
                UdacityClient.studentDataRequest(userKey: session.userKey, onCompletion: { (result) in
                    switch result {
                    case let .success(sessionWithUserData):
                        if let firstName = sessionWithUserData.firstName {
                            SharedData.shared.session.firstName = firstName
                        }
                        if let lastName = sessionWithUserData.lastName {
                            SharedData.shared.session.lastName = lastName
                        }
                        onCompletion(sessionHandlerResult)
                        break
                    case let .failure(error):
                        onCompletion(.failure(error))
                        break
                    }
                })
                break
            case let .failure(error):
                sessionHandlerResult = .failure(error)
                onCompletion(sessionHandlerResult)
                break
            }
        }
    }
    
    static func deleteSession(onCompletion: @escaping (DeleteSessionResult) -> Void) {
        var sessionHandlerResult: DeleteSessionResult!
       
        if FBSDKAccessToken.current() != nil {
            let fbLoginMgr = FBSDKLoginManager()
            fbLoginMgr.logOut()
        }
        
        UdacityClient.deleteSessionRequest { (result) in
            switch result {
            case .success:
                sessionHandlerResult = .success
                break
            case let .failure(error):
                sessionHandlerResult = .failure(error)
                break
            }
           onCompletion(sessionHandlerResult)
        }
    }
}
