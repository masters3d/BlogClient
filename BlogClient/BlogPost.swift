//
//  BlogPost.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import CoreData

func != (lhs:BlogPostData, rhs:BlogPostData) -> Bool{
    return !(lhs == rhs)
}

func == (lhs:BlogPostData, rhs:BlogPostData) -> Bool{
    return lhs.subject == rhs.subject &&
        lhs.content == rhs.content &&
        lhs.created == rhs.created &&
        lhs.last_modified == rhs.last_modified &&
        lhs.ownerid == rhs.ownerid &&
        lhs.postid == rhs.postid
}

struct BlogPostData {
    let subject: String
    let content: String
    let created: NSDate?
    let last_modified: NSDate?
    let ownerid: Int64
    let postid: Int64
}

@objc(BlogPost)
class BlogPost:NSManagedObject {

var dataStruct:BlogPostData { return BlogPostData(subject: subject ?? "", content: content ?? "", created: created, last_modified: last_modified, ownerid: ownerid, postid: postid) }
}

extension BlogPost {

convenience init(_ obj:BlogPostData){
    self.init(context:CoreDataStack.shared.viewContext)
    subject = obj.subject
    content = obj.content
    created = obj.created
    last_modified = obj.last_modified
    ownerid = obj.ownerid
    postid = obj.postid
}

func coredataCopyDataContents(_ obj:BlogPostData){
    print((CoreDataStack.shared.viewContext.mergePolicy as! NSMergePolicy).mergeType.rawValue)
    subject = obj.subject
    content = obj.content
    created = obj.created
    last_modified = obj.last_modified
    ownerid = obj.ownerid
    postid = obj.postid

}

func coredataCopyDataContentsOLD(_ obj:BlogPostData){
    self.setValue(obj.subject, forKey: "subject")
    self.setValue(obj.content, forKey: "content")
    self.setValue(obj.created, forKey: "created")
    self.setValue(obj.last_modified, forKey: "last_modified")
    self.setValue(NSNumber.init(value: obj.ownerid), forKey: "ownerid")
    self.setValue(NSNumber.init(value: obj.postid), forKey: "postid")
}



}

