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


class AWSS3ItemsTableViewController: UITableViewController {
    var toBeDownloadFileNames = [String]()
    var downloadTasks = [DataDownloader]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        getAllFileNamesFromAWSS3Server { (fileNames, error) in
            let files = fileNames as! [String]
            if (files.count >= 1){
                self.toBeDownloadFileNames = files
                self.startOperation(fileNames: fileNames as! [String])
            }else{
                self.showInfoInAlert(msg: "No file to download")
            }
            print(files)
        }
    }
    func getAllFileNamesFromAWSS3Server(completion: completionBlock?){
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
    func startOperation(fileNames:[String]) {
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
                        guard let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AWSS3ItemTableViewCell else {
                            return
                        }
                        cell.configure(task)
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
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
    // MARK: — Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toBeDownloadFileNames.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AWSS3ItemTableViewCell
        let task: DataDownloader = downloadTasks[indexPath.row]
        cell.configure(task)
        let fileName = String(toBeDownloadFileNames[indexPath.row].suffix(20))
        cell.titleLabel.text = fileName
        let image : UIImage = UIImage(named:getCellImage(fileName: fileName)) ?? UIImage(named:"blank_icon.png")!
        cell.cellIconView.image = image
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let fileDetailViewController = storyBoard.instantiateViewController(withIdentifier: "FileDetailViewControllerID") as! FileDetailViewController
        let fileUrl = getAWSDocumentsDirectoryUrl().appendingPathComponent(toBeDownloadFileNames[indexPath.row])
        fileDetailViewController.fileURL = fileUrl
        // self.present(fileDetailViewController, animated:true, completion:nil)
        self.navigationController!.pushViewController(fileDetailViewController, animated: true)
    }
    @IBAction func navigateBack(_ sender: Any) {
        // self.dismiss(animated: true, completion: nil)
        self.navigationController!.popViewController(animated: true)
    }
    func showInfoInAlert(msg:String){
        let alertController = UIAlertController(title:nil, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

