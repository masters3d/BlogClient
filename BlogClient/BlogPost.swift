//
//  BlogPost.swift
//  BlogClient
//
//  Created by Cheyo Jimenez on 10/7/16.
//  Copyright © 2016 masters3d. All rights reserved.
//

import CoreData

extension BlogPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlogPost> {
        return NSFetchRequest<BlogPost>(entityName: "BlogPost");
    }

    @NSManaged public var content: String?
    @NSManaged public var created: NSDate?
    @NSManaged public var last_modified: NSDate?
    @NSManaged public var ownerid: Int64
    @NSManaged public var postid: Int64
    @NSManaged public var subject: String?

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

//static func coreDataNewObjectWithBackgroundContext(subject: String, content: String, created: NSDate?, last_modified: NSDate?, ownerid: Int64, postid: Int64) -> BlogPost {
//    let obj = BlogPost(context:CoreDataStack.shared.backgroundContext)
//    obj.subject = subject
//    obj.content = content
//    obj.created = created
//    obj.last_modified = last_modified
//    obj.ownerid = ownerid
//    obj.postid = postid
//    return obj
//}

//func coredataCopyObjectToViewContent() -> BlogPost{
//    let obj = BlogPost(context:CoreDataStack.shared.viewContext)
//    obj.subject = subject
//    obj.content = content
//    obj.created = created
//    obj.last_modified = last_modified
//    obj.ownerid = ownerid
//    obj.postid = postid
//    return obj
//}

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
    subject = obj.subject
    content = obj.content
    created = obj.created
    last_modified = obj.last_modified
    ownerid = obj.ownerid
    postid = obj.postid
}


}



//    static func coreDataObject(height: Double, imageData: Data, title: String, width: Double, photo_id:String, pin:PinAnnotation, timeCreated:Date = Date()) -> Photo {
//        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into:  CoreDataStack.shared.viewContext) as! Photo
