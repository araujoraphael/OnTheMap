//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 13/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//
import Foundation

struct StudentInformation {
    var firstName: String?
    var lastName: String?
    var key: String?
    var objectId: String?
    var uniqueKey: String?
    var createdAt: Date?
    var updatedAt: Date?
    var location: StudentLocation?

    init(withDictionary dictionary: [String: AnyObject]) {
        key = dictionary["key"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        objectId = dictionary["objectId"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        
        location = StudentLocation(withDictionary: dictionary)
        
        if let createdAtStr = dictionary["createdAt"] as? String {
            createdAt = dateFromString(dateStr: createdAtStr)
        }
        if let updatedAtStr = dictionary["updatedAt"] as? String {
            updatedAt = dateFromString(dateStr: updatedAtStr)
        }
    }
    
    func dateFromString(dateStr: String) -> Date {
        var date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let d = dateFormatter.date(from: dateStr) {
            date = d
        }
        return date
    }
}
