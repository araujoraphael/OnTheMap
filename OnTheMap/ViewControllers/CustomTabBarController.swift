//
//  CustomTabBarController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 10/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
protocol CustomTabBarControllerDelegate : AnyObject {
    func didFinishGetStudentLocation()
    func didFailGetStudentLocation(error: Error)
    func didStartGetStudentLocation()
}
class CustomTabBarController: UITabBarController {
    var customDelegate : CustomTabBarControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.customDelegate?.didStartGetStudentLocation()
        StudentInformationHandler.getStudentsLocations { (result) in
            switch result {
            case .success:
                self.customDelegate?.didFinishGetStudentLocation()
                break
            case let .failure(error):
                self.customDelegate?.didFailGetStudentLocation(error: error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        SessionHandler.deleteSession { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                break
            case let .failure(error):
                let alert = UIAlertController(title: "",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
                alert.addAction(action)
                
                DispatchQueue.main.async{
                    self.present(alert, animated: true, completion: nil)
                }
                break
            }
        }
    }
    
    @IBAction func addLocationTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "addLocationSegue", sender: nil)
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        self.customDelegate?.didStartGetStudentLocation()
        StudentInformationHandler.getStudentsLocations { (result) in
            switch result {
            case .success:
                self.customDelegate?.didFinishGetStudentLocation()
                break
            case let .failure(error):
                self.customDelegate?.didFailGetStudentLocation(error: error)
            }
        }
    }
}
