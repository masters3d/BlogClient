//
//  BlogServerAPI.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

struct Post {
    let created:String
    let subject:String
    let content:String
    let postid:Int64
    let ownerid:Int64 // This can come back as null from the server
}

struct BlogServerAPI{
    fileprivate static let serverAddress = "https://cheyomasters3d.appspot.com/blog"
    //fileprivate static let serverAddress = "http://localhost:8080/blog"
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
    
    static func getAllPostsFromServer() -> URLRequest {
        let url = URL(string: serverAddress + ".json")!
        var request = URLRequest(url: url)
        request.addValue("ios", forHTTPHeaderField: "api")
        return request
    }
    
    static func parseJSONFromServer(_ input: [String:Any]) -> Post? {
        guard let created = input["created"] as? String else { print("created broke");return nil }
        guard let subject = input["subject"] as? String else { print("subject broke");return nil }
        guard let content = input["content"] as? String else { print("content broke");return nil }
        guard let postid = input["postid"] as? Int else { print("postid broke");return nil }
        
        let owneridString = (input["ownerid"] as? String) ?? ""
        let owneridInt64 = (input["ownerid"] as? Int64) ?? 0
        
        let ownerid = owneridString.isEmpty ? owneridInt64 : 0
        
        return Post(created: created, subject: subject, content: content, postid: Int64(postid), ownerid: ownerid)
    }
    
}
