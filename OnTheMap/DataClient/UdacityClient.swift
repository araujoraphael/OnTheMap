//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-21.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

enum StudentInformationResult {
    case success(StudentInformation)
    case failure(Error)
}

enum StudentsInformationsResult {
    case success([StudentInformation])
    case failure(Error)
}

enum StudentDataResult {
    case success(Session)
    case failure(Error)
}

enum PostStudentLocationResult {
    case success
    case failure(Error)
}

enum CreateSessionResult {
    case success(Session)
    case failure(Error)
}

enum DeleteSessionResult {
    case success
    case failure(Error)
}

enum ClientError: Error {
    case invalidJSON
}

class UdacityClient {
    
    // MARK: - Session
    static private func handleCreateSessionRequest(data: Data?, error: Error?) -> CreateSessionResult {
        guard let json = data else { return .failure(error!) }
        return UdacityAPI.session(fromJSON: json)
    }
    
    static func createSessionRequest(email: String, password: String, onCompletion: @escaping (CreateSessionResult) -> Void) {
        guard let request = UdacityAPI.sessionURLRequest(action: .createWithEmail, email, password, nil) else {
            return
        }
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            guard let e = error else {
                let range = Range(5..<data!.count)
                if let newData = data?.subdata(in: range) {
                     guard let responseHTTP = response as? HTTPURLResponse else {
                        let err = CustomError(message: "Sorry, something happens between the App and the server. Try again later", code: 666)
                        onCompletion(.failure(err))
                        return
                    }
                    guard let errorFromResponse = UdacityAPI.errorFrom(httpResponse: responseHTTP) else {
                        let requestResult = UdacityClient.handleCreateSessionRequest(data: newData, error: error)
                        onCompletion(requestResult)
                        return
                    }
                    onCompletion(.failure(errorFromResponse))
                } else {
                    onCompletion(.failure(ClientError.invalidJSON))
                }
                return
            }
            onCompletion(.failure(e))
        }
        dataTask.resume()
    }
    
    static func createSessionWithFacebookRequest(facebookToken: String, onCompletion: @escaping (CreateSessionResult) -> Void) {
        guard let request = UdacityAPI.sessionURLRequest(action: .createWithFacebook, nil, nil, facebookToken) else {
            return
        }
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            guard let e = error else {
                let range = Range(5..<data!.count)
                if let newData = data?.subdata(in: range) {
                    let requestResult = UdacityClient.handleCreateSessionRequest(data: newData, error: error)
                    onCompletion(requestResult)
                } else {
                    onCompletion(.failure(ClientError.invalidJSON))
                }
                return
            }
            onCompletion(.failure(e))
        }
        dataTask.resume()
    }
    
    static func deleteSessionRequest(onCompletion: @escaping (DeleteSessionResult) -> Void) {
        guard let request = UdacityAPI.sessionURLRequest(action: .delete, nil, nil, nil) else {
            return
        }
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            if error == nil {
                onCompletion(.success)
            } else {
                onCompletion(.failure(error!))
            }
        }
        dataTask.resume()
    }
    
    
    // MARK: - Students Locations
    static private func handleStudentsLocationsRequest(data: Data?, error: Error?) -> StudentsInformationsResult {
        guard let json = data else { return .failure(error!) }
        return UdacityAPI.studentsLocations(fromJSON: json)
    }
    
    static private func handleStudentDataRequest(data: Data?, error: Error?) -> StudentDataResult {
        guard let json = data else { return .failure(error!) }
        
        return UdacityAPI.sessionWithUserData(fromJSON: json)
    }
    
    static func studentsLocationsRequest(onCompletion: @escaping (StudentsInformationsResult) -> Void) {
        guard let request = UdacityAPI.studentLocationRequest(action: .list, userKey: nil, locationJSON: nil) else {return}
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            let requestResult = UdacityClient.handleStudentsLocationsRequest(data: data, error: error)
            onCompletion(requestResult)
        }
        dataTask.resume()
    }
    
    static func addStudentLocationRequest(userKey: String, locationJSON: [String: Any], onCompletion: @escaping (PostStudentLocationResult) -> Void) {
        guard let request = UdacityAPI.studentLocationRequest(action: .add, userKey: userKey, locationJSON: locationJSON) else {return}
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            
            guard let e = error else {
                onCompletion(.success)
                return
            }
            onCompletion(.failure(e))
        }
        dataTask.resume()
    }
    
    static func studentDataRequest(userKey: String, onCompletion: @escaping (StudentDataResult) -> Void) {
        guard let request = UdacityAPI.studentLocationRequest(action: .singleStudent, userKey: userKey, locationJSON: nil) else {return}
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            guard let e = error else {
                let range = Range(5..<data!.count)
                if let newData = data?.subdata(in: range) {
                    let requestResult = UdacityClient.handleStudentDataRequest(data: newData, error: nil)
                    onCompletion(requestResult)
                } else {
                    onCompletion(.failure(ClientError.invalidJSON))
                }
                return
            }
            onCompletion(.failure(e))
        }
        dataTask.resume()
    }
}
