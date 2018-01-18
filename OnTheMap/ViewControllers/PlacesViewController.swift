//
//  PlacesTableViewController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 12/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit

class PlacesViewController: UIViewController, CustomTabBarControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!

    private var studentsInformations = [StudentInformation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarVC = self.tabBarController as? CustomTabBarController {
            tabBarVC.customDelegate = self
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        
        if let tabBarVC = self.tabBarController as? CustomTabBarController {
            self.studentsInformations.append(contentsOf: tabBarVC.studentsInformations)
        }
    }
    
    func didStartGetStudentLocation() {
        DispatchQueue.main.async{
            self.loadingView.isHidden = false
        }
    }
    
    func didFinishGetStudentLocation(error: Bool, message: String, studentsInformations: [StudentInformation]?) {
        DispatchQueue.main.async{
            self.loadingView.isHidden = true
        }
        
        if !error {
            self.studentsInformations.removeAll()
            self.studentsInformations.append(contentsOf: studentsInformations!)
            self.tableView.reloadData()
        } else {
            let alert = UIAlertController(title: "",
                                          message: "There was an error retrieving student data.",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let studentInformation = self.studentsInformations[indexPath.row]
        
        if let urlStr = studentInformation.location?.mediaURL {
            if let url = URL(string: urlStr) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension PlacesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentsInformations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        cell.studentInformation = self.studentsInformations[indexPath.row]
        
        return cell
    }
}
