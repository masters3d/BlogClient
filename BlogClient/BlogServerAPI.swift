//
//  BlogServerAPI.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit
import CoreData

// Server Date ISO Formatter
extension Date{
    static let serverISOFormatter = { () -> DateFormatter in let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "PST")! // Server Timezone
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return dateFormat
    }()
}

struct BlogServerAPI{
//    fileprivate static let serverAddress = "https://cheyomasters3d.appspot.com/blog"
    fileprivate static let serverAddress = "http://localhost:8080/blog"
    fileprivate static let serverLogin = serverAddress + "/login"
    fileprivate static let serverSignup = serverAddress + "/signup"
}

extension BlogServerAPI {
    static func loginRequest(username:String, password:String) -> URLRequest {
        let urlParams =  NetworkOperation.componentsMaker(baseUrl: serverLogin, querryKeyValue: ["username":username, "password": password])
        var request = URLRequest(url: urlParams!.url!)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = true
        request.addValue("ios", forHTTPHeaderField: "api")
        return request
    }
    
    static func signupRequest(username:String, password:String, verifypass:String, email:String) -> URLRequest {
        let querry = ["username":username, "password": password, "verify":verifypass, "email":email ]
        let urlParams = NetworkOperation.componentsMaker(baseUrl: serverSignup, querryKeyValue: querry)
        var request = URLRequest(url: urlParams!.url!)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = true
        request.addValue("ios", forHTTPHeaderField: "api")
        return request
    }
    
    static func getAllPostsFromServer(){
        let url = URL(string: serverAddress + ".json")!
        var request = URLRequest(url: url)
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation.init(urlRequest: request, sessionName: "allBlogPost", errorDelegate: nil) { (data, response) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let array = json as? [[String:Any]] else { return }
            //let scratchMangedContex = CoreDataStack.shared.backgroundContext
            for each in array {
                guard let postData = parseJSONFromServer(each) else {
                    print("post could not be decoded")
                    continue
                }
                
                CoreDataStack.shared.performBackgroundTask({ (objectContext) in
                   
                
                
                let fetchRequest:NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "postid == %@", argumentArray: [postData.postid])
                
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_modified", ascending: false)]

                //TODO:-- Got to try to get this from GDC and do try catch so see the errror.
                
                var found = [BlogPost]()
                
                do {
                  found =  try objectContext.fetch(fetchRequest)
                } catch {
                    print(error)
                }
                
                guard let first = found.first
                    else {
                           // This creates the post on core data
                          // _ = BlogPost(post)
                          // CoreDataStack.shared.saveContext()
                            return }
                
                //if !(first.dataStruct == postData) {
                    //first.coredataCopyDataContents(post)
                    //CoreDataStack.shared.saveContext()
                //}
            }) // end of background task
            }
            //CoreDataStack.shared.saveContext()
        }
        requestOperation.start()
    }
    

    
    static func parseJSONFromServer(_ input: [String:Any]) -> BlogPostData? {
        guard let created = input["created"] as? String else { print("created broke");return nil }
        guard let subject = input["subject"] as? String else { print("subject broke");return nil }
        guard let content = input["content"] as? String else { print("content broke");return nil }
        guard let last_modified = input["last_modified"] as? String else { print("last_modified broke");return nil }
        guard let postid = input["postid"] as? Int else { print("postid broke");return nil }
        let owneridString = (input["ownerid"] as? String) ?? "" // Ownerid can come back as null from the server
        let owneridInt64 = (input["ownerid"] as? Int) ?? 0
        let ownerid = owneridString.isEmpty ? owneridInt64 : 0
        
        // These ISO String date needs to converted to NSDATE so we can format them nicely for the user
        let createdDate = Date.serverISOFormatter.date(from: created) as NSDate?
        let last_modifiedDate = Date.serverISOFormatter.date(from: last_modified) as NSDate?

        return BlogPostData(subject: subject, content: content,created: createdDate, last_modified:last_modifiedDate, ownerid: Int64(ownerid), postid: Int64(postid))
    }
    
}
