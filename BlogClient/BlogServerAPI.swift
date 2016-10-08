//
//  BlogServerAPI.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import UIKit

struct BlogServerAPI{
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
}
