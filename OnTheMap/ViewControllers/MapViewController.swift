//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 10/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import MapKit
import Foundation
class MapViewController: UIViewController, CustomTabBarControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingView: UIView!
    private var studentsInformations = [StudentInformation]()
    private var mapAnnotations = [MapAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBarVC = self.tabBarController as? CustomTabBarController {
            tabBarVC.customDelegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didStartGetStudentLocation() {
        DispatchQueue.main.async {
          self.loadingView.isHidden = false
        }
    }
    
    func didFinishGetStudentLocation(error: Bool, message: String, studentsInformations: [StudentInformation]?) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
        }
        
        if !error {
            self.mapView.removeAnnotations(self.mapAnnotations)
            self.mapAnnotations.removeAll()
            self.studentsInformations.removeAll()
            self.studentsInformations.append(contentsOf: studentsInformations!)
            
            for studentInformation in self.studentsInformations {
                var studentName = ""
                
                if let firstName = studentInformation.firstName, let lastName = studentInformation.lastName {
                    studentName = "\(firstName) \(lastName)"
                }
                
                if let studentLocation = studentInformation.location {
                    if let latitude = studentLocation.latitude, let longitude = studentLocation.longitude {
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let annotation = MapAnnotation(title: studentName,
                                                       subtitle: studentInformation.location!.mediaURL!,
                                                       coordinate:  location )
                        self.mapAnnotations.append(annotation)
                    }
                }
            }
            self.mapView.addAnnotations(self.mapAnnotations)
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

extension MapViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let tap = UITapGestureRecognizer(target:self,  action:#selector(calloutTapped(sender:)))
        view.addGestureRecognizer(tap)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
    
    @objc func calloutTapped(sender:UITapGestureRecognizer) {
        let view = sender.view as! MKAnnotationView
        if let annotation = view.annotation as? MapAnnotation {
            if let url = URL(string: annotation.subtitle!) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
