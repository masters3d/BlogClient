//
//  NewPostAndEdit.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/13/16.
//  Copyright © 2016 masters3d. All rights reserved.
//


import UIKit
import CoreData

class NewPostAndEdit:UIViewController, ErrorReporting {
    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var contentField: UITextView!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var postLabel: UIButton!
    @IBOutlet weak var deleteLabel: UIButton!
    @IBAction func deleteOnServer(_ sender: UIButton) {
    }
    @IBAction func postToServer(_ sender: UIButton) {
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       print( view.gestureRecognizers?.count)
        //TODO:- change this so it is not fixed
         view.frame.origin.y = -130
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.frame.origin.y = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentField.layer.borderColor =  UIColor.gray.cgColor
        self.contentField.layer.borderWidth = 0.25
        self.contentField.layer.cornerRadius = 5.0
        self.contentField.clipsToBounds = true
        //Keyboard Delegate
        self.contentField.delegate = self
        self.subjectField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}
