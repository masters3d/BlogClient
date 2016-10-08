//
//  ViewController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/6/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func login(_ sender: UIButton) {
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

