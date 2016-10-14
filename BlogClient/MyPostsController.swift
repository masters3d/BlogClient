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
   lazy var fetchedResultsController:NSFetchedResultsController<BlogPost> = DataController.shared.createFetchController(predicate: NSPredicate(format: "ownerid == %@", argumentArray: [Int(UserDefaults.getUserIdSaved())]))
    
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
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.rowHeight = 200
    }
    
    func handleRefresh(){
        BlogServerAPI.getAllPostsFromServer(delegate: self)
    }
    
    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (self.fetchedResultsController.sections ?? []).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let indexPath = IndexPath.init(row: 0, section: section)
        let name = DataController.shared.getUserNameForUserId(fetchedResultsController.object(at: indexPath).ownerid)
        return "User: \(name)"
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPostsTableCell", for: indexPath) as! TableViewCell
        //TODO:- Need to set up the cell here for content. Can I do different size content?
        let object = self.fetchedResultsController.object(at: indexPath)
        cell.postTitle.text = object.subject
        cell.postContent.text = object.content?.replacingOccurrences(of: "<br>", with: "\n")
        cell.postOwner.text = "by: \(DataController.shared.getUserNameForUserId(object.ownerid))"
        cell.lastModified.text = DateFormatter.localizedString(from: (object.last_modified as? Date) ?? Date(), dateStyle: .medium, timeStyle: .medium)
        cell.accessoryType = .detailButton

        return cell
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let url = URL.init(string: BlogServerAPI.serverAddress + "/\(fetchedResultsController.object(at: indexPath).postid)")!
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO:- I should probalby show a seprate view to edit the blog post
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
        self.activityIndicatorStop()
    }
    
    //Table view Editing - Deleting.
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let id = UserDefaults.getUserIdSaved()
        if fetchedResultsController.object(at: indexPath).ownerid == id  {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let object = fetchedResultsController.object(at: indexPath)
            BlogServerAPI.deletePostFromServer(postId: object.postid, delegate: self) {_,_ in
                // success block
                DataController.shared.deletePersistedObject(object)
            }
          
        default:
            break
        }
    
    }
}




