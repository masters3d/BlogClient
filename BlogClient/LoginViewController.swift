//
//  ViewController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/6/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, ErrorReporting {

    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
    
        guard let username = username.text,
            let password = password.text else {
                DispatchQueue.main.async {
                    self.presentErrorPopUp("Please enter Username and Password")
                }
                return // exit scope
            }
        let request = BlogServerAPI.loginRequest(username: username, password: password)
        let operation = NetworkOperation(urlRequest: request, sessionName: "loginOperation", errorDelegate: self) { (data, response) in
            guard let response = response,
                let serverResponse = response.allHeaderFields["server-response"] as? String
                else { DispatchQueue.main.async {
                    self.presentErrorPopUp("There was an network error") }
                    return }
            if serverResponse == "success" {
                print(response)
                UserDefaults.setCookie(with: response)
                UserDefaults.setUserCredentials(username: username, password: password)
                print(HTTPCookieStorage.shared.cookies)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.presentErrorPopUp(serverResponse)
                }
            }
        }
    operation.start()
    }
    
    // Error handeling for Data
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let (username, password ) = UserDefaults.getUserCredentials() {
            self.username.text = username
            self.password.text = password
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assingDelegateToTextFields(textFields)
        if let (username, password ) = UserDefaults.getUserCredentials(),
         let cookie = UserDefaults.getCookie(){
            self.username.text = username
            self.password.text = password
        
        if let _ =  HTTPCookieStorage.shared.cookies?.filter({$0.value == cookie.value}).first {
            print("Found cookie")
        }
            else { HTTPCookieStorage.shared.setCookie(cookie) }
        }
    }
    
    // Activity updating from network
    func activityIndicatorStart() {
        activity.startAnimating()
    }
    func activityIndicatorStop() {
        activity.stopAnimating()
    }
    
}



