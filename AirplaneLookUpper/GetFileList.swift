//
//  AWSS3ItemsTableViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/15.
//

import UIKit
import AWSCognito
import AWSCore
import AWSS3


class GetFileList{
    var toBeDownloadFileNames = [String]()
    var downloadTasks = [DataDownloader]() {
        didSet {
            //ダウンロードが終わったら？
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
    }
    
    func getAllFileNamesFromAWSS3Server (bucketName:String,completion: completionBlock?) -> [String]{
        
//        let listObjectsRequest = AWSS3ListObjectsV2Request()
//        listObjectsRequest?.bucket = bucketName
//        //listObjectsRequest?.prefix = prefix. //If you want to have a prefix
//        //listObjectsRequest?.delimiter = delimiter //If you want to have a delimiter
//        AWSS3.default().listObjectsV2(listObjectsRequest!) { (output, error) in
//          if let error = error{
//             print(error)
//          }
//          if let output = output{
//             print(output)
//          }
//        }

        let s3 = AWSS3.default()
        let listRequest: AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        listRequest.bucket = bucketName
        var allFiles = [String]()
        s3.listObjects(listRequest).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Error occurred: \(error)")
                return nil
            }
            if ((task.result?.contents) != nil){
                for object in (task.result?.contents)! {
                    // print(“Object key = \(object.key!)")
                    allFiles.append(object.key!)
                }
            }
            if let completionBlock = completion {
                completionBlock(allFiles, nil)
            }
            return nil
        }

        print(allFiles)
        return allFiles
    }
    
    func getAllFileFromAWSS3Server(completion: completionBlock?){
        AWSS3Manager.shared.downloadAllFilesFromAWSBucket(progress: { (progress) in
            print(progress)
        }) {(fileUrls, error) in
            if error == nil {
                print(fileUrls!)
                if let completionBlock = completion {
                    completionBlock(fileUrls, nil)
                }
            }else{
                if let completionBlock = completion {
                    completionBlock(nil, error)
                }
            }
        }
    }
}
            



//        AWSS3Manager.shared.downloadAllFilesFromAWSBucket(progress: { (progress) in
//            print(progress)
//        }) {(fileUrls, error) in
//            if error == nil {
//                print(fileUrls!)
//                setString(string: fileUrls as! [String])
//                if let completionBlock = completion {
//                    completionBlock(fileUrls, nil)
//                }
//            }else{
//                if let completionBlock = completion {
//                    completionBlock(nil, error)
//                }
//            }
//            contentsList = fileUrls as! [String]
//        }
//
//        func setString(string:[String]){
//            contentsList = string
//        }
//
//        print("result = \(contentsList)")
//        return contentsList
   

