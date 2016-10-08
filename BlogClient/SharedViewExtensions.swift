//
//  SharedViewExtensions.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/8/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

extension ErrorReporting where Self : UIViewController  {


    // Log out for all views
    func logoutPerformer() {
        let logoutActionSheet = UIAlertController(title: "Confirmation Required", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let logoutConfirmed = UIAlertAction(title: "Logout", style: .destructive, handler: { Void in
            self.activityIndicatorStart()
            UserDefaults.logout()
            if let cookies = HTTPCookieStorage.shared.cookies {
                for each in cookies {
                    if each.name == "name" {
                        HTTPCookieStorage.shared.deleteCookie(each)
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        })

        logoutActionSheet.addAction(logoutConfirmed)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutActionSheet.addAction(cancel)
        present(logoutActionSheet, animated: true, completion: {
            self.isAlertPresenting = false
            self.activityIndicatorStop()
        })
    }

}
