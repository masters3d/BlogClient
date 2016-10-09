//
//  MyPostController.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/8/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit


class MyPostsController:UITableViewController, ErrorReporting {
    // Error Handeling
    var errorReported: Error?
    var isAlertPresenting: Bool = false
    
    func activityIndicatorStart() {
        self.refreshControl?.beginRefreshing()
    }
    func activityIndicatorStop() {
        self.refreshControl?.endRefreshing()
    }
    
    var content:[Post] = [] {didSet{ self.tableView.reloadData()}}
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.logoutPerformer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        let requestOperation = NetworkOperation.init(urlRequest: BlogServerAPI.getAllPostsFromServer(), sessionName: "allBlogPost", errorDelegate: self) { (data, response) in
            guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let array = json as? [[String:Any]] else { return }
            
            DispatchQueue.main.async {
                
                for each in array {
                guard let post = BlogServerAPI.parseJSONFromServer(each) else {
                print("post could not be decoded")
                continue
                }
                print(post)
                self.content.append(post)
            }
                
            self.tableView.reloadData()
            }
        }
        requestOperation.start()
        
    }
    
    func handleRefresh(){
    //TODO:- code to handle the pull down refresh of the table
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO:- Should I do different rows? Should I use a fetch contoller here?
        return content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myPostsTableCell", for: indexPath)
        //TODO:- Need to set up the cell here for content. Can I do different size content?
        cell.detailTextLabel?.text = content[indexPath.row].content
        cell.textLabel?.text = content[indexPath.row].content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO:- I should probalby show a seprate view to edit the blog post
    }
    
}
