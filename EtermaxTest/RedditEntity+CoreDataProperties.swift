//
//  RedditEntity+CoreDataProperties.swift
//  EtermaxTest
//
//  Created by Gustavo Alfonso on 10/4/17.
//  Copyright © 2017 Gustavo Alfonso. All rights reserved.
//

import Foundation
import CoreData


extension RedditEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RedditEntity> {
        return NSFetchRequest<RedditEntity>(entityName: "RedditEntity");
    }

    @NSManaged public var author: String?
    @NSManaged public var commentsCount: Int16
    @NSManaged public var creationDate: Int64
    @NSManaged public var subreddit: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?

}
