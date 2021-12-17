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
        
        

    }
    @IBAction func CloseShootResult(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- AWS file download
    // fileName : name of file, like “SampleVImage.jpg” “SampleVideoClip.mp4”
    // progress: file download progress, value from 0 to 1, 1 for 100% complete
    // completion: completion block when uplaoding is finish, we will get S3 url of upload file here
    
    
    
    
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


