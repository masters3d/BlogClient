//
//  DataController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import CoreData

class DataController {

   static let shared = DataController()
   private static let shareCoreData = CoreDataStack()
    
    var errorHandlerDelegate:ErrorReporting? { didSet{
        if let delegate = errorHandlerDelegate {
            CoreDataStack.shared.errorHandler = delegate.reportErrorFromOperation
        } else {
            CoreDataStack.shared.errorHandler = { _ in }
        }}}


}
