//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-21.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

enum SessionAction: String {
    case createWithEmail = "createWithEmail"
    case createWithFacebook = "createWithFacebook"
    case delete = "delete"
}

enum StudentLocationAction: String {
    case list = "list"
    case singleStudent = "singleStudent"
    case add = "add"
}

struct UdacityAPI {
    private static let udacityURL = "https://www.udacity.com/api"
    private static let parseURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    private static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    private static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    static func studentLocationRequest(action: StudentLocationAction, userKey: String?, locationJSON: [String: Any]?) ->  URLRequest? {
        
        var url: URL = URL(string: "\(parseURL)?limit=100&order=-updatedAt")!
        let httpMethod: String!
        let httpBody: Data?
        var urlRequest = URLRequest(url: url)

        switch action {
        case .list:
            guard let u = URL(string: "\(parseURL)?limit=100&order=-updatedAt") else { return nil }
            url = u
            httpMethod = "GET"
        case .singleStudent:
            guard let u = URL(string: "\(udacityURL)/users/\(userKey!)") else { return nil }
            url = u
            httpMethod = "GET"
        case .add:
            guard let u = URL(string: parseURL) else { return nil }
            url = u
            httpMethod = "POST"
            let firstName = locationJSON!["firstName"] as! String
            let lastName = locationJSON!["lastName"] as! String
            let mapString = locationJSON!["mapString"] as! String
            let urlString  = locationJSON!["mediaURL"] as! String
            let latitude = locationJSON!["latitude"] as! Double
            let longitude = locationJSON!["longitude"] as! Double

            let httpBodyString = "{\"uniqueKey\": \"\(userKey!)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(urlString)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
            
            httpBody = httpBodyString.data(using: .utf8)
            urlRequest.httpBody = httpBody
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


        }
        urlRequest.url = url
        urlRequest.httpMethod = httpMethod
        urlRequest.addValue(applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        urlRequest.addValue(APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        return urlRequest
    }
    
    static func studentsLocations(fromJSON jsonData: Data) -> StudentsInformationsResult {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
        
            if let json = json as? [String: AnyObject] {
                if let _ = json["error"] as? String{
                    return .failure(ClientError.invalidJSON)
                } else {
                    guard let studentsInformationsJSONArray = json["results"] as? [[String: AnyObject]] else {
                        return .failure(ClientError.invalidJSON)
                    }
                    var studentsInformations = [StudentInformation]()

                    for studentLocationJSON in studentsInformationsJSONArray {
                        if let studentInformation = StudentInformation(withDictionary: studentLocationJSON) {
                            studentsInformations.append(studentInformation)
                        }
                    }
                    
                    if studentsInformations.count == 0 {
                        return .failure(ClientError.invalidJSON)
                    } else {
                        return .success(studentsInformations)
                    }
                }
            } else {
                return .failure(ClientError.invalidJSON)
            }
        } catch {
            return .failure(ClientError.invalidJSON)
        }
    }
        
//MARK: - Session
    static func sessionURLRequest(action: SessionAction, _ username: String?, _ password: String?, _ facebookToken: String? ) ->  URLRequest? {
        guard let url = URL(string: "\(udacityURL)/session") else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        switch action {
        case .createWithEmail:
            guard let username = username else { break }
            guard let password = password else { break }
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
            
        case .createWithFacebook:
            guard let token = facebookToken else { break }
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = "{\"facebook_mobile\":{\"access_token\": \"\(token) \"}}".data(using: .utf8)
            
        case .delete:
            urlRequest.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                urlRequest.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            
        }
        return urlRequest
    }
    
    static func session(fromJSON jsonData: Data) -> CreateSessionResult {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
            if let json = json as? [String: AnyObject] {
                if let _ = json["error"] as? String{
                    return .failure(ClientError.invalidJSON)
                } else {
                    guard let session = Session(withDictionary: json) else {
                        return .failure(ClientError.invalidJSON)
                    }
                    return .success(session)
                }
            } else {
                return .failure(ClientError.invalidJSON)
            }
        } catch {
            return .failure(ClientError.invalidJSON)
        }
    }
    
    static func sessionWithUserData(fromJSON jsonData: Data) -> StudentDataResult {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
            if let json = json as? [String: AnyObject] {
                
                if let _ = json["error"] as? String{
                    return .failure(ClientError.invalidJSON)
                } else {
                    guard let session = Session(withUserDataDictionary: json) else {
                        return .failure(ClientError.invalidJSON)
                    }
                    return .success(session)
                }
            } else {
                return .failure(ClientError.invalidJSON)
            }
        } catch {
            return .failure(ClientError.invalidJSON)
        }
    }
    
    //MARK: - Errors
    
    static func errorFrom(httpResponse: HTTPURLResponse) -> Error? {
        if Array(200...226).contains(httpResponse.statusCode) {
            return nil
        }
        
        if Array(500...599).contains(httpResponse.statusCode) {
            return CustomError(message: "The server is not responding", code: httpResponse.statusCode)
        }
        
        if Array(400...499).contains(httpResponse.statusCode) {
            switch httpResponse.statusCode {
            case 401:
                return CustomError(message: "Error authorizing data access. Verify your email / password.", code: 401)
            case 403:
                return CustomError(message: "Invalid credentials. Verify your email / password.", code: 403)
            case 440:
                return CustomError(message: "Session Expired. Try to log in again", code: 403)
            default:
                return CustomError(message: "Access Error", code: httpResponse.statusCode)
            }
        }
        return nil
    }
    
}
