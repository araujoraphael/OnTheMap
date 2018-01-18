//
//  Session.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 16/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import Foundation

struct Session {
    var userKey: String!
    var firstName: String?
    var lastName: String?
    init(withDictionary dictionary: [String: AnyObject]) {
        if let accountJson = dictionary["account"] as? [String: AnyObject] {
            userKey = accountJson["key"] as! String
        }
    }
}
