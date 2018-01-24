//
//  CustomError.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-23.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

class CustomError: Error {
    var code: Int = 0
    var message: String = ""
    init(message: String, code: Int) {
        self.message = message
        self.code = code
    }
}
