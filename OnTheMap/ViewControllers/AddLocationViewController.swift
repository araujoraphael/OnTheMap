//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 13/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import MapKit
class AddLocationViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func areFieldsValid() -> Bool {
        if self.locationTextField.text == "" {
            return false
        }
        
        if self.locationTextField.text == nil {
            return false
        }
        
        if self.urlTextField.text == "" {
            return false
        }
        
        if self.urlTextField.text == nil {
            return false
        }
        
        return true
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func findLocationTapped(_ sender: Any) {
        
        if areFieldsValid() {
            self.activityIndicator.startAnimating()
            
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = self.locationTextField.text!
            
            let localSearch = MKLocalSearch(request: searchRequest)
            localSearch.start { (response, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                if error != nil {
                    let alert = UIAlertController(title: "",
                                                  message: error?.localizedDescription,
                                                  preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if let resp = response {
                        if resp.mapItems.count > 0 {
                            if let mapItem = resp.mapItems.first {
                                if let url = URL(string: self.urlTextField.text!) {
                                    mapItem.url = url
                                    self.performSegue(withIdentifier: "showLocationSegue", sender: mapItem)
                                } else {
                                    let alert = UIAlertController(title: "",
                                                                  message: "Invalid URL format.",
                                                                  preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
                                    alert.addAction(action)
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Required fields",
                                          message: "You must enter a Location and a valid Website",
                                          preferredStyle: .alert)
            
            let action = UIAlertAction(title: "DISMISS", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLocationSegue" {
            if let mapItem = sender as? MKMapItem {
                if let foundLocationVC = segue.destination as? FoundLocationViewController {
                    foundLocationVC.mapItem =  mapItem
                }
            }
        }
    }
}
