//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Cheyo Jimenez on 9/29/16.
//  Copyright © 2016 masters3d. All rights reserved.
//


import CoreData

final class CoreDataStack {
 
    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = {print($0)}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { [weak self](storeDescription, error) in
            if let error = error {
                NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
                self?.errorHandler(error)
            }
            print("Core Data set")
            })
        
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.perform {
            block(self.viewContext)
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                NSLog("CoreData Save error \(error), \(String(describing: error._userInfo))")
                self.errorHandler(error)
            }
        }
    }
    
}
