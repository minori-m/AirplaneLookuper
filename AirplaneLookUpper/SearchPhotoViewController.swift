//
//  SearchPhotoViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/14.
//

import UIKit
import AWSCognito
import AWSCore
import AWSS3


class SearchPhotoViewController: UIViewController {
    
    @IBOutlet weak var callsignInput: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    let bucketName = "myairplanetest"
    var contentsList = [String]()
    
    var toBeDownloadFileNames = [String]()
    var downloadTasks = [DataDownloader]() {
        didSet {
            DispatchQueue.main.async {
                //self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //AWSS3ListObjectsOutput.contents
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let GetFileList_instance = GetFileList()
        
        GetFileList_instance.getAllFileFromAWSS3Server { (fileNames, error) in
            let files = fileNames as! [String]
            print("files=\(files)")
            if (files.count >= 1){
                self.toBeDownloadFileNames = files
                self.downloadContents(fileNames: fileNames as! [String])
            }else{
                //self.showInfoInAlert(msg: "No file to download")
            }
            print(files)
        }
        
//        let callsign = callsignInput.text!
//        print(callsign)
//        self.getBucketContentsList()
//        DispatchQueue.main.async {
//            //let downloadfileName = self.contentsList[0]
//            //print(downloadfileName)
//            //AWSS3ItemsTableViewController_instance.startOperation(fileNames: ["AAL9728 .png"])
//            //let AWSS3Manager_instance = AWSS3Manager()
//            //AWSS3Manager.shared.justDownloadFile(fileName: "AAL9728 .png")
//            self.downloadContents(fileNames: ["AAL9728 .png"])
//        }
        //        let storyBoard : UIStoryboard = UIStoryboard(name: “Main”, bundle:nil)
        //        let nextViewController = storyBoard.instantiateViewController(withIdentifier: “tableViewStoryID”) as! AWSS3ItemsTableViewController
        //        //self.present(nextViewController, animated:true, completion:nil)
        //        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    @IBAction func CloseShootResult(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- AWS file download
    // fileName : name of file, like “SampleVImage.jpg” “SampleVideoClip.mp4”
    // progress: file download progress, value from 0 to 1, 1 for 100% complete
    // completion: completion block when uplaoding is finish, we will get S3 url of upload file here
    
    
    func getBucketContentsList(){
        let GetFileList_instance = GetFileList()
        //self.contentsList = GetFileList_instance.getAllFileNamesFromAWSS3Server(bucketName: bucketName)
        print("bucketName=\(bucketName)")
        print("self.bucketName=\(self.bucketName)")
        
        print("contents = \(self.contentsList)")
        
    }
    
    func downloadContents(fileNames:[String]){
        downloadTasks = []
        let dispatchQueue = DispatchQueue(label: "com.awss3.test", qos: .userInitiated, attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 5)
        downloadTasks = (1...fileNames.count).map({ (i) -> DataDownloader in
            let identifier = "\(i)"
            return DataDownloader(identifier: identifier, stateUpdateHandler: { (task) in
                DispatchQueue.main.async { [unowned self] in
                    guard let index = self.downloadTasks.indexOfTaskWith(identifier: identifier) else {
                        return
                    }
                    switch task.state {
                    case .completed:
                        print("Completed")
                    case .pending, .inProgess(_):
                        print("inProgress")
                        //guard let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AWSS3ItemTableViewCell else {
//                            return
//                        }
//                        cell.configure(task)
//                        self.tableView.beginUpdates()
//                        self.tableView.endUpdates()
                    }
                }
            })
        })
        for (index, element) in downloadTasks.enumerated() {
            element.startTask(queue: dispatchQueue, group: dispatchGroup, semaphore: dispatchSemaphore, downloadfileName: fileNames[index])
        }
        dispatchGroup.notify(queue: .main) { [unowned self] in
            // self.showInfoInAlert(msg: “All Download tasks has been completed”)
            print("All Download tasks has been completed")
            // self.tableView.reloadData()
        }
    }
    
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


