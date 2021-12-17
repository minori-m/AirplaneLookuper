//
//  DownloadsCollectionViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/17.
//

import UIKit

import AWSS3

class DownloadsCollectionViewController: UIViewController {
    let bucketName = "myairplanetest"
    var contentsList = [String]()
    
    var toBeDownloadFileNames = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    @objc var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    
    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()
    
    var downloadTasks = [DataDownloader]() {
        didSet {
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let GetFileList_instance = GetFileList()
        
        GetFileList_instance.getAllFileFromAWSS3Server { (fileNames, error) in
            let files = fileNames as! [String]
            print("files=\(files)")
            if (files.count >= 1){
                self.toBeDownloadFileNames = files
                
            }else{
                //self.showInfoInAlert(msg: "No file to download")
            }
            print(files)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
    }
    
    
}

extension DownloadsCollectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toBeDownloadFileNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SampleCell
        
        let post = toBeDownloadFileNames[indexPath.item]
        cell.title = post.description
        
        cell.image = nil
        //cell.badge = nil
        
        let representedIdentifier = post
        cell.representedIdentifier = representedIdentifier
        
        func image(data: Data?) -> UIImage? {
            if let data = data {
                return UIImage(data: data)
            }
            return UIImage(systemName: "picture")
        }
        let expression = AWSS3TransferUtilityDownloadExpression()
        
        self.completionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("Failed with error: \(error)")
                    //self.statusLabel.text = "Failed"
                }
//                else if(self.progressView.progress != 1.0) {
//                    self.statusLabel.text = "Failed"
//                }
                else{
                    //self.statusLabel.text = "Success"
                    cell.image = image(data: data!)
                }
            })
        }
        print("success1")
        transferUtility.downloadData(
            fromBucket: self.bucketName, key: "AAL9728 .png", expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    NSLog("Error: %@",error.localizedDescription);
                    DispatchQueue.main.async(execute: {
                        //self.statusLabel.text = "Failed"
                    })
                }
                
                if let _ = task.result {
                    DispatchQueue.main.async(execute: {
                        //self.statusLabel.text = "Downloading..."
                    })
                    NSLog("Download Starting!")
                    // Do something with uploadTask.
                }
                return nil;
            }
        
//        networker.image(post: post) { data, error  in
//            let img = image(data: data)
//            DispatchQueue.main.async {
//                if (cell.representedIdentifier == representedIdentifier) {
//                    cell.image = img
//                }
//            }
//        }
//
//        networker.profileImage(post: post) { data, error  in
//            let img = image(data: data)
//            DispatchQueue.main.async {
//                if (cell.representedIdentifier == representedIdentifier) {
//                    cell.badge = img
//                }
//            }
//        }
        
        return cell
    }
    
}
