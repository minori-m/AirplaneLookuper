//
//  CollectionViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/17.
//

import UIKit

class CollectionViewController: UICollectionViewController{
    let bucketName = "myairplanetest"
    var contentsList = [String]()
    
    var toBeDownloadFileNames = [String]()
    
    @IBOutlet weak var collectionViewCell: UICollectionViewCell!
    
    
    var downloadTasks = [DataDownloader]() {
        didSet {
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UINib(nibName: "UICollectionElementKindCell", bundle:nil)
        
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
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
                        guard let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? SampleCell else {
                            return
                        }
                        //let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "thiscell", for: IndexPath(row: index, section: 0)) as! SampleCell
                        cell.image = UIImage(data: task.imageData)
                        print(task.imageData)
                        //cell.configure(task)
//                        self.collectionView.beginUpdates()
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("num of cell is \(toBeDownloadFileNames.count)")
        return toBeDownloadFileNames.count // 表示するセルの数
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath ) -> UICollectionViewCell {
//
//        // "Cell" はストーリーボードで設定したセルのID
//        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "thiscell", for: indexPath)
//        // Tag番号を使ってImageViewのインスタンス生成
//        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
//        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
//        //let cellImage = UIImage(named: photos[indexPath.row])
//        let url = getAWSDocumentsDirectoryUrl().appendingPathComponent(toBeDownloadFileNames[indexPath.row]).absoluteString
//        print("url=\(url)")
//        let cellImage = UIImage(url:url)
//        print("line 100 end")
//        // UIImageをUIImageViewのimageとして設定
//        imageView.image=cellImage
//        return testCell
//    }
//    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
