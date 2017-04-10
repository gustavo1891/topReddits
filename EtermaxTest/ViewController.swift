//
//  ViewController.swift
//  EtermaxTest
//
//  Created by Gustavo Alfonso on 6/4/17.
//  Copyright © 2017 Gustavo Alfonso. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var infoArray : [RedditEntity] = []
    var isEditingInfo : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.contentInset.top = 20
        tableView.register(UINib(nibName: "RedditTableViewCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        infoArray = DataManager.sharedInstance.getDataFromDB()
        self.tableView.reloadData()
        if ConnectionManager.sharedInstance.isInternetAvailable() {
            self.isEditingInfo = true
            ConnectionManager.sharedInstance.searchTopReddits { (error, message, objects) in
                self.infoArray = objects
                self.tableView.reloadData()
                self.isEditingInfo = false
            }
        }
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: .none, queue: OperationQueue.main) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - UITableViewDelegate UITableViewDataSourse
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (infoArray.count + 1)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.infoArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedditCell", for: indexPath as IndexPath) as! RedditTableViewCell
            let obj = infoArray[indexPath.row] as RedditEntity
            cell.lblAuthor?.text = obj.author
            cell.lblTitle?.text = obj.title
            cell.lblTitle?.sizeToFit()
            cell.lblComments?.text = String(obj.commentsCount)
            cell.lblSubreddit?.text = obj.subreddit
            if ((indexPath.row % 2) == 1) {
                cell.backgroundColor = UIColor(colorLiteralRed: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
            }else{
                cell.backgroundColor = UIColor.white
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm"
            let timeZone = NSTimeZone(name: "UTC")
            dateFormatter.timeZone = timeZone as TimeZone!
            let date = NSDate(timeIntervalSince1970:TimeInterval(obj.creationDate))
            cell.lblDate?.text = dateFormatter.string(from: date as Date )
            if let urlString = obj.thumbnail {
                if obj.thumbnail != "default"  {
                    cell.img?.af_setImage(withURL: NSURL(string: urlString)! as URL)
                }else{
                    cell.img?.image = UIImage(named: "defaultImg.png")
                }
                
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadCell", for: indexPath as IndexPath) as! LoadingCell
            cell.progress?.startAnimating()
            if (ConnectionManager.sharedInstance.isInternetAvailable()) {
                if(!self.isEditingInfo){
                    self.isEditingInfo = true
                    ConnectionManager.sharedInstance.getRedditNextPage(delegate: self)
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                return cell
            }
            
            
            
            
        }
        
    }
    
    //MARK: - ConnectionManagerDelegate
    func remoteDataLoaded(results: [RedditEntity]) {
        self.isEditingInfo = false
        self.infoArray.append(contentsOf: results)
        self.tableView.reloadData()
    }
    
    func connectionDidFail(error: NSError) {
        self.isEditingInfo = false
    }
}

