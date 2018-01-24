//
//  SharedData.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 2018-01-19.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

class SharedData: NSObject {
    static let shared = SharedData()
    var studentsInformations = [StudentInformation]()
    var session:Session!
    var isLoadingLocations = false
}
