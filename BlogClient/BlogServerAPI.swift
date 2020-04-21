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
extension Date {
    static let serverISOFormatter = { () -> DateFormatter in let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")! // Server Timezone
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return dateFormat
    }()
    
}

struct BlogServerAPI{
     static let serverAddress = "https://cheyomasters3d.appspot.com/blog"
//    static let serverAddress = "http://localhost:8080/blog"
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
    
    static func getHeadersFromSavedCookies() -> [String : String] {
       if let cookie = UserDefaults.getCookie() {
            return HTTPCookie.requestHeaderFields(with: [cookie] )
       } else {
            return [:]
       }
    }
    
    static func deletePostFromServer(postId:Int64, delegate:ErrorReporting,
    successBlock:@escaping (Data?, HTTPURLResponse?) -> Void = { (data, response) in print("succesfully deleted")}) {
        let url = URL(string: serverAddress + "/\(postId)")!
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.allHTTPHeaderFields = getHeadersFromSavedCookies()
        request.httpMethod = "DELETE"
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation(urlRequest: request, sessionName: "deletePostID-\(postId)", errorDelegate: delegate, successBlock: successBlock)
        requestOperation.start()
    }
    
        static func addNewPostToServer(title:String,content:String, delegate:ErrorReporting,
    successBlock:@escaping (Data?, HTTPURLResponse?) -> Void = { (data, response) in print("succesfully added new post")}) {
    
        let querry = ["subject":title, "content": content]
        let urlParams = NetworkOperation.componentsMaker(baseUrl: serverAddress + "/newpost", querryKeyValue: querry)
            
        var request = URLRequest(url: urlParams!.url!)
        request.httpShouldHandleCookies = true
        request.allHTTPHeaderFields = getHeadersFromSavedCookies()
        request.httpMethod = "POST"
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation(urlRequest: request, sessionName: "newPost", errorDelegate: delegate, successBlock: successBlock)
        requestOperation.start()
    }
    
    static func updatePostOnServer(postId:Int64, title:String,content:String, delegate:ErrorReporting,
    successBlock:@escaping (Data?, HTTPURLResponse?) -> Void = { (data, response) in print("succesfully added new post")}) {
    
        let querry = ["subject":title, "content": content]
        let urlParams = NetworkOperation.componentsMaker(baseUrl: serverAddress + "/\(postId)", querryKeyValue: querry)
            
        var request = URLRequest(url: urlParams!.url!)
        request.httpShouldHandleCookies = true
        request.allHTTPHeaderFields = getHeadersFromSavedCookies()
        request.httpMethod = "POST"
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation(urlRequest: request, sessionName: "updatePost\(postId)", errorDelegate: delegate, successBlock: successBlock)
        requestOperation.start()
    }
    
    
    
    static func getUsernameWithId(_ userID:Int64,delegate:ErrorReporting?) {
        let url = URL(string: serverAddress + "/userid/" + "\(userID)")!
        var request = URLRequest(url: url)
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation.init(urlRequest: request, sessionName: "requestUserNameFor\(userID)", errorDelegate: delegate) { (data, response) in
            guard let response = response,
                let serverResponse = response.allHeaderFields["server-response"] as? String
                else { DispatchQueue.main.async {
                    delegate?.reportErrorFromOperation(NSError.init(domain: "There was an error getting user name for post", code: 0, userInfo: nil)) }
                    return }
                UserDefaults.idToUserMap[String(userID)] = serverResponse
        }
        requestOperation.start()
    }
    
    static func getAllPostsFromServer(delegate:ErrorReporting, successBlock: @escaping () -> Void = {}){
        let url = URL(string: serverAddress + ".json")!
        var request = URLRequest(url: url)
        request.addValue("ios", forHTTPHeaderField: "api")
        let requestOperation = NetworkOperation.init(urlRequest: request, sessionName: "allBlogPost", errorDelegate: delegate) { (data, response) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let array = json as? [[String:Any]]
                    else {
                        NSLog("There was a error in getAllPostsFromServer")
                        return
                    }
            
            var allCoreDataResults = [BlogPost]()
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = CoreDataStack.shared.viewContext
            
            context.performAndWait {
                let fetchRequest:NSFetchRequest<BlogPost> = BlogPost.fetchRequest()
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_modified", ascending: false)]
                
                do {
                  allCoreDataResults =  try fetchRequest.execute()
                } catch {
                    print(error)
                }
            
            let resultsServer = array.compactMap(parseJSONFromServer)
            
            // Detect when blog post are deleted outside of the app.
            if resultsServer.count < allCoreDataResults.count {
                    let postIdFromServer = resultsServer.map({$0.postid})
                    let postIdnotOnServer = allCoreDataResults.map({$0.dataStruct.postid}).filter({!postIdFromServer.contains($0)})
                    let objectsToRemove = allCoreDataResults.filter({postIdnotOnServer.contains($0.postid)})
                
                    objectsToRemove.forEach({ (coreDataBlogPost) in
                        context.delete(coreDataBlogPost)
                    })
                   _ = try? context.save()
            }
            
            resultsServer.forEach({ (postData) in
                guard let first = allCoreDataResults.filter({$0.postid == postData.postid}).first
                    else {   // This creates the post on core data
                           _ = BlogPost(postData)
                           CoreDataStack.shared.saveContext()
                            return }
                
                if (first.dataStruct != postData) {
                    first.coredataCopyDataContents(postData)
                       do {
                        try first.managedObjectContext?.save()
                       } catch {
                            print("there was an error saving update to coredataobject")
                            print(error)
                       }
                    }
                successBlock()
                })
            }
        } // End Of context
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
        
        // These ISO String date needs to converted so we can format them nicely for the user
        let createdDate = Date.serverISOFormatter.date(from: created)
        let last_modifiedDate = Date.serverISOFormatter.date(from: last_modified)

        return BlogPostData(subject: subject, content: content,created: createdDate, last_modified:last_modifiedDate, ownerid: Int64(ownerid), postid: Int64(postid))
    }
    
}
