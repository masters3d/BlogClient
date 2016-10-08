//
//  UserDefaults.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/8/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func setCookie(with response:HTTPURLResponse) {
        guard let fields = response.allHeaderFields as? [String : String],
            let url = URL(string: "/"),
            let cookie = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url).first
            else { return }
        let archiveCookie = NSKeyedArchiver.archivedData(withRootObject: cookie)
        standard.set(archiveCookie, forKey: "cookie") //HTTPCookie
    }
    
    static func getCookie() -> HTTPCookie? {
        guard let data = standard.data(forKey: "cookie"),
            let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data),
            let cookie = unarchived as? HTTPCookie
            else { return nil }
        return cookie
    }
    
    static func setUserCredentials(username:String, password:String) {
        standard.set(password, forKey: "password")
        standard.set(username, forKey: "username")
    }
    
    static func getUserCredentials() -> (username:String, password:String)? {
        guard let name = standard.string(forKey: "username"),
            let password = standard.string(forKey: "password")
            else { return nil }
        return (name, password)
    }
    
    static func logout() {
        standard.set(nil, forKey: "username")
        standard.set(nil, forKey: "password")
        standard.set(nil, forKey: "cookie")
    }
    
}
