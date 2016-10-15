//
//  ViewController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/6/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, ErrorReporting {

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) { }

    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let identifier = segue.identifier else {print("Invalide identifier"); return}
        switch identifier {
        case "loginSegue":
            //iniciate a new view controller
            (segue.destination as! UITabBarController).createBlogViewController()
        default:
            break
        }
    }
    
    @IBOutlet weak var loginButton: UIButton!
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
                    self.presentErrorPopUp("There was a network error") }
                    return }
            if serverResponse == "success" {
                print(response)
                UserDefaults.setCookie(with: response)
                UserDefaults.setUserCredentials(username: username, password: password)
                self.perfromLoginSeque()
            } else {
                DispatchQueue.main.async {
                    self.presentErrorPopUp(serverResponse)
                }
            }
        }
    operation.start()
    }
    
    func perfromLoginSeque() {
            BlogServerAPI.getAllPostsFromServer(delegate: self) {
              DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
    }
    
    // Error handeling for Data
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let (username, password ) = UserDefaults.getUserCredentials(),
           let cookie = UserDefaults.getCookie(){
            self.username.text = username
            self.password.text = password
            
            // setting cookie if not set
            if let _ =  HTTPCookieStorage.shared.cookies?.filter({$0.value == cookie.value}).first {}
                else { HTTPCookieStorage.shared.setCookie(cookie) }
        } else {
            self.username.text = ""
            self.password.text = ""
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assingDelegateToTextFields(textFields)
       HTTPCookieStorage.shared.cookieAcceptPolicy = .always
       
       //If there is a cookies saved. Continue to data
        if let _ = UserDefaults.getCookie() {
            perfromLoginSeque()
        }
    }
    
    // Activity updating from network
    func activityIndicatorStart() {
        activity.startAnimating()
        self.loginButton.isEnabled = false
    }
    func activityIndicatorStop() {
        activity.stopAnimating()
        self.loginButton.isEnabled = true
    }
    
}



