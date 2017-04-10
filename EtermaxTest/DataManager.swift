//
//  DataManager.swift
//  EtermaxTest
//
//  Created by Gustavo Alfonso on 6/4/17.
//  Copyright © 2017 Gustavo Alfonso. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class DataManager: NSObject {
    
    private override init() { }
    static let sharedInstance: DataManager = DataManager()

    func isEmptyLists(dict: [String: [String]]) -> Bool {
        for list in dict.values {
            if !list.isEmpty { return false }
        }
        return true
    }
    
    func parseRedditResults(results:Any) -> [RedditEntity]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        let json = JSON(results)
        var topReddits: [RedditEntity] = []
        var records = json["data"]
        if let jsonArr:[JSON] = records["children"].array {
            for redditJSON in jsonArr {
                
                // Parse Object
                var objectData = redditJSON["data"]
                let obj = NSEntityDescription.insertNewObject(forEntityName:"RedditEntity", into:context) as! RedditEntity
                obj.author = objectData["author"].string
                obj.commentsCount = objectData["num_comments"].int16!
                obj.creationDate = objectData["created_utc"].int64!
                obj.subreddit = objectData["subreddit"].string
                obj.thumbnail = objectData["thumbnail"].string
                obj.title = objectData["title"].string
                
                topReddits.append(obj)
                
            }
        }
        saveResults(context: context)
        return topReddits
    }
    
    
    //MARK: - CoreData
    func saveResults(context:NSManagedObjectContext) -> Bool {
        do {
            try context.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        return true
    }
    
    func getDataFromDB()->[RedditEntity]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        var objects = [RedditEntity]()
        let employeesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "RedditEntity")
        
        do {
            objects = try context.fetch(employeesFetch) as! [RedditEntity]
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        return objects
    }
    
    func deleteAllRecords() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()

        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "RedditEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    

}
