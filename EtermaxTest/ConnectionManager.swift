//
//  ConnectionManager.swift
//  EtermaxTest
//
//  Created by Gustavo Alfonso on 6/4/17.
//  Copyright © 2017 Gustavo Alfonso. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import Alamofire
import SwiftyJSON
import CoreData

class ConnectionManager:NSObject{
    
    private override init() { }
    static let sharedInstance: ConnectionManager = ConnectionManager()
    let searchEndpointURL = "https://www.reddit.com/top/.json"
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    

    func searchTopReddits(_ CallbackParameter: @escaping (_ error : NSError?, _ message : String?, _ objects: [RedditEntity]) -> ()){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        // Display an Activity Indicator in the status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var topReddits: [RedditEntity] = []
        
        
        Alamofire.request(searchEndpointURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                DataManager.sharedInstance.deleteAllRecords()
                let json = JSON(value)
                var records = json["data"]
                if let jsonArr:[JSON] = records["children"].array {
                    for redditJSON in jsonArr {
                        
                        // Parse Object
                        var objectData = redditJSON["data"]
                        let obj = NSEntityDescription.insertNewObject(forEntityName:"RedditEntity", into:context) as! RedditEntity
                        obj.author = objectData["author"].string
                        obj.commentsCount = objectData["num_comments"].int16!
                        obj.creationDate = objectData["created_utc"].int16!
                        obj.subreddit = objectData["subreddit"].string
                        obj.thumbnail = objectData["thumbnail"].string
                        obj.title = objectData["title"].string
                        
                        topReddits.append(obj)
                        
                    }
                }
                
                // Dismiss an Activity Indicator in the status bar
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                do {
                    try context.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                CallbackParameter(nil, "Success", topReddits)
                
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                CallbackParameter(error as NSError?, "Error", topReddits)
            }
        }
        
    }

    
}
