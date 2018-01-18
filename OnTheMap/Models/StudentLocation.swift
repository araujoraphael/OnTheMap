//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 14/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//
struct StudentLocation {
    
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    
    init(withDictionary dictionary: [String: AnyObject]) {
        
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
    }
}
