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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarVC = self.tabBarController as? CustomTabBarController {
            tabBarVC.customDelegate = self
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
    }
    
    func didStartGetStudentLocation() {
        DispatchQueue.main.async{
            self.loadingView.isHidden = false
        }
    }
    
    func didFinishGetStudentLocation() {
        DispatchQueue.main.async{
            self.loadingView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    func didFailGetStudentLocation(error: Error) {
        let alert = UIAlertController(title: "",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
        alert.addAction(action)
        
        DispatchQueue.main.async{
            self.loadingView.isHidden = true
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let studentInformation = SharedData.shared.studentsInformations[indexPath.row]
        
        if let urlStr = studentInformation.location?.mediaURL {
            if let url = URL(string: urlStr) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension PlacesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.shared.studentsInformations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        cell.studentInformation = SharedData.shared.studentsInformations[indexPath.row]
        
        return cell
    }
}
