//
//  StudentInformationHandler.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-22.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import Foundation
import MapKit
enum StudentInformationHandlerResult {
    case success
    case failure(Error)
}
struct StudentInformationHandler {
    static func getStudentsLocations(onComplete: @escaping (StudentInformationHandlerResult) -> Void) {
        SharedData.shared.isLoadingLocations = true
        UdacityClient.studentsLocationsRequest { (result) in
            SharedData.shared.isLoadingLocations = false
            switch result {
            case let .success(studentsInformations):
                SharedData.shared.studentsInformations = studentsInformations
                onComplete(.success)
                break
            case let .failure(error):
                onComplete(.failure(error))
                break
            }
        }
    }
    
    static func addStudentLocation(mapItem: MKMapItem, onCompletion: @escaping (StudentInformationHandlerResult) -> Void) {
        var json = [String: Any]()
        json.updateValue(mapItem.url!.absoluteString, forKey: "mediaURL")
        json.updateValue(mapItem.placemark.coordinate.latitude, forKey: "latitude")
        json.updateValue(mapItem.placemark.coordinate.longitude, forKey: "longitude")
        json.updateValue(mapItem.placemark.name!, forKey: "mapString")
        json.updateValue(SharedData.shared.session.firstName!, forKey: "firstName")
        json.updateValue(SharedData.shared.session.lastName!, forKey: "lastName")
        
        let userKey = SharedData.shared.session.userKey!
        
        UdacityClient.addStudentLocationRequest(userKey: userKey, locationJSON: json) { (result) in
            switch result {
            case .success:
                onCompletion(.success)
                break
            case let .failure(error):
                onCompletion(.failure(error))
                break
            }
        }
    }
}
