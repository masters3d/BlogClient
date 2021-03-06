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

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize =
            userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // this needs to be overitten by class that wants keboard support
    @objc func keyboardWillShow(_ notification: Notification) {
        // Get keyboard gets the current size of the keyboard
        //view.frame.origin.y = -getKeyboardHeight(notification)
    }

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
