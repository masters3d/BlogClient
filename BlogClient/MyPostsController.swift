//
//  MyPostController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/8/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import CoreData

class MyPostsController:UITableViewController, ErrorReporting, NSFetchedResultsControllerDelegate {

    //Core Data
    var fetchedResultsController:NSFetchedResultsController<BlogPost> = {
            let temp:NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
            temp.sortDescriptors = [NSSortDescriptor(key: "last_modified", ascending: false)]
            temp.returnsObjectsAsFaults = false
            //temp.predicate = NSPredicate.init(format: "ownerid == %@", argumentArray: [5171003185430528])
            var nfrc = NSFetchedResultsController<BlogPost>.init(fetchRequest: temp, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
            do {
                try nfrc.performFetch()
            } catch {
                print(error)
            }
            return nfrc
            }()
    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false
    
    func activityIndicatorStart() {
        self.refreshControl?.beginRefreshing()
    }
    func activityIndicatorStop() {
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.logoutPerformer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        self.fetchedResultsController.delegate = self
        BlogServerAPI.getAllPostsFromServer(delegate: self)
    }
    
    func handleRefresh(){
        BlogServerAPI.getAllPostsFromServer(delegate: self)
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO:- Should I do different rows? Should I use a fetch contoller here?
        let sectionInfo = self.fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPostsTableCell", for: indexPath)
        //TODO:- Need to set up the cell here for content. Can I do different size content?
        let object = self.fetchedResultsController.object(at: indexPath)
        cell.detailTextLabel?.text = object.content
        cell.textLabel?.text = object.content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO:- I should probalby show a seprate view to edit the blog post
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
        self.activityIndicatorStop()
    }
}



