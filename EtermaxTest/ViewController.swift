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

//Milliseconds to date
extension Int64 {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var infoArray :[RedditEntity] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.contentInset.top = 20
        tableView.register(UINib(nibName: "RedditTableViewCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        infoArray = DataManager.sharedInstance.getDataFromDB()
        self.tableView.reloadData()
        if ConnectionManager.sharedInstance.isInternetAvailable() {
            ConnectionManager.sharedInstance.searchTopReddits { (error, message, objects) in
                self.infoArray = objects
                self.tableView.reloadData()
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


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        dateFormatter.locale = Locale.init(identifier: "UTC")
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        let newDate = now - Int64(obj.creationDate)
        cell.lblDate?.text = dateFormatter.string(from: newDate.dateFromMilliseconds())
        if let urlString = obj.thumbnail {
            cell.img?.af_setImage(withURL: NSURL(string: urlString)! as URL) 
        }
        
        return cell
    }
}

