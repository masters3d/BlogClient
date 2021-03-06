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

    func deletePersistedObject(_ object:NSManagedObject) {
        CoreDataStack.shared.viewContext.delete(object)
        CoreDataStack.shared.saveContext()
    }
    
    func getUserNameForUserId(_ id:Int64) -> String {
        
        if id == 0 { return "unknown" }
        
        if let username = UserDefaults.idToUserMap[String(id)] {
            return username
        } else {
        BlogServerAPI.getUsernameWithId(id, delegate: nil)
        return String(id)
        }
    }
    
    func createFetchController(predicate:NSPredicate?, returnAsFaults:Bool = false ) -> NSFetchedResultsController<BlogPost>{
            let temp:NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
            temp.sortDescriptors = [NSSortDescriptor(key: "last_modified", ascending: false)]
            temp.returnsObjectsAsFaults = returnAsFaults
            temp.predicate = predicate
            let nfrc = NSFetchedResultsController<BlogPost>.init(fetchRequest: temp, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: "ownerid", cacheName: nil)
            do {
                try nfrc.performFetch()
            } catch {
                print(error)
            }
            return nfrc
            }


}
