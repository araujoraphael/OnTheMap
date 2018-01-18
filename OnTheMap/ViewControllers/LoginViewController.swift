//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Raphael Araújo on 10/01/18.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class LoginViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tapBackground: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUpTapped(sender: AnyObject) {
        if let signUpURL = URL(string: "https://auth.udacity.com/sign-up") {
            if UIApplication.shared.canOpenURL(signUpURL) {
                UIApplication.shared.open(signUpURL)
            }
        }
    }
    
    @IBAction func logInTapped(sender: AnyObject) {
        self.view.endEditing(true)

        if self.emailTextField.text! == "" || self.passwordTextField.text! == "" {
            let errorAlert = UIAlertController(title: "Login error",
                                               message: "Missing Email or Password",
                                               preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            errorAlert.addAction(action)
            self.present(errorAlert, animated: true, completion: nil)
            return
        }
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
        DataManager.createSession(username: self.emailTextField.text!,
                                  password: self.passwordTextField.text!)
        {(error, message) in
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                if error == false {
                    self.performSegue(withIdentifier: "mapViewSegue", sender: nil)
                } else {
                    let errorAlert = UIAlertController(title: "Login error",
                                                       message: message,
                                                       preferredStyle: .alert)
                    let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    errorAlert.addAction(action)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func fbLoginTapped(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
        let fbLoginMgr: FBSDKLoginManager =  FBSDKLoginManager.init()
        
        fbLoginMgr.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            if error != nil {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                return
            } else if result!.isCancelled{
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                print("login canceled by user")
            } else {
                if FBSDKAccessToken.current() != nil {
                    if let fbToken = FBSDKAccessToken.current().tokenString {
                        DataManager.createSession(withFacebookToken: fbToken) { (error, message) in
                            DispatchQueue.main.async {
                                self.view.isUserInteractionEnabled = true
                                self.activityIndicator.stopAnimating()
                                if error == false {
                                    self.performSegue(withIdentifier: "mapViewSegue", sender: nil)
                                } else {
                                    let errorAlert = UIAlertController(title: "Login error",
                                                                       message: message,
                                                                       preferredStyle: .alert)
                                    let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                                    errorAlert.addAction(action)
                                    self.present(errorAlert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    @IBAction func backgroundTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
}
