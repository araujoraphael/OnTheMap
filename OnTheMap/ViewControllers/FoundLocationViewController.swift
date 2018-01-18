//
//  FoundLocationViewController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 15/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import MapKit
class FoundLocationViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!

    var mapItem: MKMapItem?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let pm = mapItem?.placemark {
            let coordinate = pm.coordinate
            let coordinateSpam = MKCoordinateSpan(latitudeDelta: 0.002 as Double, longitudeDelta: 0.002 as Double)
            let region = MKCoordinateRegion(center: coordinate,
                                            span: coordinateSpam)
            
            self.mapView.setRegion(region, animated: true)
            
            var annotationTitle = ""
            
            if let locality = pm.locality {
                annotationTitle += locality
            }
            
            if let administrativeArea = pm.administrativeArea {
                annotationTitle += ", \(administrativeArea)"
            }
            
            if let country = pm.country {
                annotationTitle += ", \(country)"
            }
            
            let annotation = MapAnnotation(title: pm.name!,
                                           subtitle: annotationTitle,
                                           coordinate: pm.coordinate)
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        self.loadingView.isHidden = false
        DataManager.postStudentLocation(mapItem: self.mapItem!) { (error, message) in
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                
                if error == true {
                    let alert = UIAlertController(title: "Error trying add location",
                                                  message: message,
                                                  preferredStyle: .alert)
                    let action = UIAlertAction(title: "DISMISS", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension FoundLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapAnnotation else { return nil }
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
        }
        return view
    }
}


