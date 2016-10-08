//
//  ViewController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/6/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordVerify: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBAction func signup(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assingDelegateToTextFields(textFields)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

