//
//  DataManager.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 13/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit
class DataManager: NSObject {
    var session:Session!
    static let shared: DataManager = DataManager()
    
    class func createSession(username: String, password:String, onCompletion:@escaping (_ error: Bool, _ message: String) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                onCompletion(true, error!.localizedDescription)
            } else {
                let range = Range(5..<data!.count)
                if let newData = data?.subdata(in: range) {
                    do {
                        let parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)

                        if let json = parsedResult as? [String: AnyObject] {
                            if let e = json["error"] as? String{
                                onCompletion(true, e)
                            } else {
                                DataManager.shared.session = Session(withDictionary: json)
                                DataManager.getStudentData()
                                onCompletion(false, "Success")
                            }
                        } else {
                            onCompletion(true, "Error parsing json")
                        }
                    } catch {
                        onCompletion(true, "Error parsing data")
                    }
                }
            }
        }
        task.resume()
    }
    
    class func createSession(withFacebookToken token: String, onCompletion:@escaping (_ error: Bool, _ message: String) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(token) \"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                onCompletion(true, error!.localizedDescription)
            } else {
                let range = Range(5..<data!.count)
                if let newData = data?.subdata(in: range) {
                    do {
                        let parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
                        
                        if let json = parsedResult as? [String: AnyObject] {
                            if let e = json["error"] as? String{
                                onCompletion(true, e)
                            } else {
                                DataManager.shared.session = Session(withDictionary: json)
                                DataManager.getStudentData()
                                onCompletion(false, "Success")
                            }
                        } else {
                            onCompletion(true, "Error parsing json")
                        }
                    } catch {
                        onCompletion(true, "Error parsing data")
                    }
                }
            }
        }
        task.resume()
    }
    
    class func deleteSession(onCompletion:@escaping (_ error: Bool, _ message: String) -> Void) {
        
        if FBSDKAccessToken.current() != nil {
            let fbLoginMgr = FBSDKLoginManager()
            fbLoginMgr.logOut()
        }
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                onCompletion(true, "Error trying logout user")
            } else {
                onCompletion(false, "Success!")
            }
        }
        task.resume()
    }
    
    class func getStudentLocations(onCompletion: @escaping (_ error: Bool, _ message: String, _ sutdentsInformations: [StudentInformation]? )-> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                onCompletion(true, error.debugDescription, nil)
                return
            }
            do {
                let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
                if let json = parsedResult as? [String: AnyObject] {
                    if let e = json["error"] as? String{
                        onCompletion(true, e, nil)
                    } else {
                        var studentsInformations = [StudentInformation]()

                        if let studentsJson = json["results"] as? [[String: AnyObject]] {
                            for studentJson in studentsJson {
                                let studentInformation = StudentInformation(withDictionary: studentJson)
                                if studentInformation.uniqueKey == DataManager.shared.session.userKey {
                                    DataManager.shared.session.firstName = studentInformation.firstName
                                    DataManager.shared.session.lastName = studentInformation.lastName

                                }
                                studentsInformations.append(studentInformation)
                            }
                        }
                        onCompletion(false, "Success", studentsInformations)
                    }
                } else {
                    onCompletion(true, "Error parsing json", nil)
                }
            } catch {
                onCompletion(true, "Error parsing data", nil)
            }
        }
        task.resume()
    }
    
    class func getStudentData() {
        guard let userKey = DataManager.shared.session.userKey else {
            return
        }
        if let url = URL(string: "https://www.udacity.com/api/users/\(userKey)") {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error...
                    print(error)
                    return
                } else {
                    let range = Range(5..<data!.count)
                    if let newData = data?.subdata(in: range) {
                        do {
                            let parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
                            if let json = parsedResult as? [String: AnyObject] {
                                if let e = json["error"] as? String{
                                    print(">>>> error \(e)")
                                } else {
                                    if let userJson = json["user"] as? [String: AnyObject] {
                                        DataManager.shared.session.firstName = userJson["first_name"] as? String
                                        DataManager.shared.session.lastName = userJson["last_name"] as? String
                                    }
                                }
                            } else {
                                print("Error parsing json")
                            }
                        } catch {
                            print("Error parsing json")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    class func postStudentLocation(mapItem: MKMapItem, onCompletion: @escaping (_ error: Bool, _ message: String)-> Void) {
        if let locationUrl = mapItem.url {
            var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(DataManager.shared.session.userKey!)\", \"firstName\": \"\(DataManager.shared.session.firstName!)\", \"lastName\": \"\(DataManager.shared.session.lastName!)\",\"mapString\": \"\(mapItem.placemark.name!)\", \"mediaURL\": \"\(locationUrl.absoluteString)\",\"latitude\": \(mapItem.placemark.coordinate.latitude as Double), \"longitude\": \(mapItem.placemark.coordinate.longitude as Double)}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    onCompletion(true, error.debugDescription)
                } else {
                    onCompletion(false, "Success")
                }
            }
            task.resume()
        }
    }
}
