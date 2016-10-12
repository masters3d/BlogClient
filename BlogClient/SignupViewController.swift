//
//  ViewController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/6/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,ErrorReporting {
    
    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordVerify: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBAction func signup(_ sender: UIButton) {
    
     guard let username = username.text,
            let password = password.text,
            let passwordVerify = passwordVerify.text else {
                DispatchQueue.main.async {
                    self.presentErrorPopUp("Please enter Username, Password and verify Password")
                }
                return // exit scope
            }
        
        if username.isEmpty || password.isEmpty {
            DispatchQueue.main.async {
                self.presentErrorPopUp("Username or Password fields can't be blank")
            }
            return // exit scope
        }
        
        if password !=  passwordVerify {
            DispatchQueue.main.async {
                self.presentErrorPopUp("Passwords do no match")
            }
        }
        
        let request = BlogServerAPI.signupRequest(username: username, password: password, verifypass: passwordVerify, email: email.text ?? "")
        let operation = NetworkOperation(urlRequest: request, sessionName: "signupOperation", errorDelegate: self) { (data, response) in
            guard let response = response,
                let serverResponse = response.allHeaderFields["server-response"] as? String
                else { DispatchQueue.main.async {
                    self.presentErrorPopUp("There was an network error") }
                    return }
            if serverResponse == "success" {
                print(response)
                DispatchQueue.main.async {
                    UserDefaults.setCookie(with: response)
                    UserDefaults.setUserCredentials(username: username, password: password)
                    self.performSegue(withIdentifier: "signupToLogin", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.presentErrorPopUp(serverResponse)
                }
            }
        }
        
    operation.start()
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assingDelegateToTextFields(textFields)
    }
    
    // Activity updating from network
    func activityIndicatorStart() {
        activity.startAnimating()
    }
    func activityIndicatorStop() {
        activity.stopAnimating()
    }

}


