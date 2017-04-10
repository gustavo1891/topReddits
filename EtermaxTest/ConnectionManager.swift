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

protocol ConnectionManagerDelegate {
    func remoteDataLoaded(results:[RedditEntity])
    func connectionDidFail(error:NSError)
}

class ConnectionManager:NSObject{
    
    private override init() { }
    static let sharedInstance: ConnectionManager = ConnectionManager()
    let searchEndpointURL = "https://www.reddit.com/top/.json"
    var delegate : ConnectionManagerDelegate?
    var redditPage = 1
    var nextPage = ""
    
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
        
        // Display an Activity Indicator in the status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var topReddits: [RedditEntity] = []
        
        
        Alamofire.request(self.searchEndpointURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                DataManager.sharedInstance.deleteAllRecords()
                let json = JSON(value)
                var records = json["data"]
                self.nextPage = records["after"].string!
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                topReddits = DataManager.sharedInstance.parseRedditResults(results: value)
                CallbackParameter(nil, "Success", topReddits)
            case .failure(let error):
                print("Request failed with error: \(error)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                CallbackParameter(error as NSError?, "Error", topReddits)
            }
        }
        
    }

    func getRedditNextPage(delegate:ConnectionManagerDelegate){
        self.delegate = delegate
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var topReddits: [RedditEntity] = []
        let url = "\(self.searchEndpointURL)?count=\(25*self.redditPage)&after=\(self.nextPage)"

        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var records = json["data"]
                self.nextPage = records["after"].string!
                topReddits = DataManager.sharedInstance.parseRedditResults(results: value)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.redditPage = self.redditPage + 1
                self.delegate?.remoteDataLoaded(results: topReddits)
            case .failure(let error):
                print("Request failed with error: \(error)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.delegate?.connectionDidFail(error: error as NSError)
            }
        }

    }
    
}
