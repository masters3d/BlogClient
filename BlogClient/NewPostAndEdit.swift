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
    
    var editingMode = false
    var postToEditOnServer:BlogPost?
    
    @IBAction func deleteOnServer(_ sender: UIButton) {
        if sender.titleLabel?.text == "Delete" {
        guard let object = postToEditOnServer else { return }
            BlogServerAPI.deletePostFromServer(postId: object.postid, delegate: self) {_,_ in
                // success block
                DataController.shared.deletePersistedObject(object)
                DispatchQueue.main.sync {
                [weak self] () -> Void in
                 _ =  self?.navigationController?.popViewController(animated: true)
                }
        }
        }
        if sender.titleLabel?.text == "Cancel" {
            self.dismiss(animated: true, completion: nil )
        }
    }
    
    func setUpForEditing() {
        self.actionLabel.text = "Edit Entry"
        self.deleteLabel.setTitleColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), for: .normal)
        self.deleteLabel.setTitle("Delete", for: .normal)
        self.postLabel.setTitle("Update", for: .normal)
        // we are disabeling this button here for now.
        self.deleteLabel.isHidden = true
        
        if let post = postToEditOnServer {
            subjectField.text = post.subject
            contentField.text = post.content
        }
    }
    
   override var prefersStatusBarHidden: Bool { return !editingMode }
    
    @IBAction func postToServer(_ sender: UIButton) {
    
    guard let title = subjectField.text, let content = contentField.text else { return }
    
    guard !title.isEmpty && !content.isEmpty else { self.presentErrorPopUp("Text fields can't be blank"); return }
    
        if sender.titleLabel?.text == "Post" {
            BlogServerAPI.addNewPostToServer(title: title, content: content, delegate: self) { (data, response) in
                // checking to see if tehre was some kind of response then dismiss
                if let _ = data {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil )
                }
            }
            }
        }
        if sender.titleLabel?.text == "Update" {
            guard let object = postToEditOnServer else { print("no post passed in to edit"); return }
            BlogServerAPI.updatePostOnServer(postId: object.postid, title: title, content: content, delegate: self) { (data, response) in
                print(response)
                if let _ = response {
                    DispatchQueue.main.async {
                 _ =  self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // activity update
    func activityIndicatorStart() {
        self.activity.startAnimating()
    }
    func activityIndicatorStop() {
        self.activity.stopAnimating()
    }
    
    //kepping keyboardHeight so we can react to switching fields
    var keyboardHeight:CGFloat = 0
    func viewOffSetForKeyboard() -> CGFloat {
        let point = contentField.superview?.convert(contentField.frame.origin, to: nil)
        let yLocation = point!.y + contentField.frame.height + 28 // 28 is the buttons heigh
        let yDiference = view.frame.height - yLocation // difference between height and yLoc
        return -(keyboardHeight - yDiference)
    }
    override func keyboardWillShow(_ notification: Notification) {
        keyboardHeight = getKeyboardHeight(notification)
        if self.contentField.isFirstResponder {
            view.frame.origin.y = viewOffSetForKeyboard()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
        //Editing Mode
        if editingMode {
            setUpForEditing()
        }
    }
}
