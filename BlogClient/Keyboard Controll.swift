//
//  Keyboard Controll.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//
import UIKit

//MARK:-Keyboard code
//Call assingDelegateToTextFields() on the controllers you want to inheric this code. 


extension UIViewController:UITextFieldDelegate, UITextViewDelegate {

    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    // this needs to be overitten by class that wants keboard support
    func keyboardWillShow(_ notification: Notification) {
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // Hide the keyboard when user hits the return key
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // This function gets called inside the view so to set the instance as the delegate
    func setDelegate(_ field: UITextField) {
        field.delegate = self
    }

    func assingDelegateToTextFields(_ fields: [UITextField]) {
        
        for each in fields {
            setDelegate(each)
        }
    }

    // Automaticly sets the deltegates to all the UITextFields including the sub views
    // This is fragile and it breaks when there are stack views
    func assingDelegateToTextFields() {

        // recursive function to find all the sub views in a view
        func getAllSubViews(_ input: [UIView]) -> [UIView] {

            if input.isEmpty {
                return []
            }

            let collection = input.filter({$0.subviews.count < 1})
            var total = collection

            total += collection.flatMap({ subView in
                getAllSubViews(subView.subviews)
            })

            return total

        }
        let allSubViews = getAllSubViews(view.subviews)

        for each in  allSubViews {
        if let field = each as? UITextField{
                setDelegate(field)
            }
        }
    }

}
