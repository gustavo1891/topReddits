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

class DataManager: NSObject {
    
    private override init() { }
    static let sharedInstance: DataManager = DataManager()

    func isEmptyLists(dict: [String: [String]]) -> Bool {
        for list in dict.values {
            if !list.isEmpty { return false }
        }
        return true
    }
    
    func parseRedditInfo(records:NSDictionary){
        print("\(records["children"])")
    }
    
    
    //MARK: - CoreData
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
