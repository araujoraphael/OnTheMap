//
//  CustomTabBarController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 10/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
protocol CustomTabBarControllerDelegate : AnyObject {
    func didFinishGetStudentLocation(error: Bool, message: String, studentsInformations: [StudentInformation]?)
    func didStartGetStudentLocation()
}
class CustomTabBarController: UITabBarController {
    var customDelegate : CustomTabBarControllerDelegate?
    var studentsInformations = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.customDelegate?.didStartGetStudentLocation()
        DataManager.getStudentLocations { (error, message, studentsInformations) in
            DispatchQueue.main.async {
                self.prepareForSendingStudentsInformations(error: error,
                                                           message: message,
                                                           studentsInformations: studentsInformations)
            }
        }
    }

    func prepareForSendingStudentsInformations(error: Bool, message: String, studentsInformations: [StudentInformation]?) {
        if error == false {
            if let studentsInformationsSet = studentsInformations {
                let sortedArray = studentsInformationsSet.sorted(by: {$0.updatedAt!.timeIntervalSince1970 > $1.updatedAt!.timeIntervalSince1970})
                self.studentsInformations.removeAll()
                self.studentsInformations.append(contentsOf: sortedArray)
                self.customDelegate?.didFinishGetStudentLocation(error: error,
                                                                 message: message,
                                                                 studentsInformations: self.studentsInformations)
            } else {
                self.customDelegate?.didFinishGetStudentLocation(error: true, message: "No locations to show", studentsInformations: nil)
            }
        } else {
            self.customDelegate?.didFinishGetStudentLocation(error: error, message: message, studentsInformations: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        DataManager.deleteSession { (error, message) in
            if error {
                return
            } else {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addLocationTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "addLocationSegue", sender: nil)
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        self.customDelegate?.didStartGetStudentLocation()
        DataManager.getStudentLocations { (error, message, studentsInformations) in
            DispatchQueue.main.async {
                self.prepareForSendingStudentsInformations(error: error,
                                                           message: message,
                                                           studentsInformations: studentsInformations)
            }
        }
    }
}
