//
//  ShootResultViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/13.
//

import UIKit
import SwiftUI

import AWSCognito
import AWSCore
import AWSS3 // 追加


class ShootResultViewController: UIViewController {
    
    @IBOutlet var closeButton:UIButton!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet var airplaneLabel:UILabel!
    @IBOutlet var uploadButton:UIButton!
    
    var airplaneLabel_text = ""
    
    //撮影画面で撮影した画像
    var resultImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePreview.image = resultImage
        //        print("received \(airplaneLabel_text)")
        print("received \(self.airplaneLabel_text)")
        self.airplaneLabel.text = self.airplaneLabel_text
    }
    
    @IBAction func CloseShootResult(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}




extension ShootResultViewController: UIImagePickerControllerDelegate {
    
    // UIButtonをタップした時に発動
    @IBAction func uploadImage(_ sender: UIButton){
        print("upload tapped")
        if let pngImage = resultImage!.pngData() {
               uploadData(data: pngImage) // 追加
            }
        
        //picker.dismiss(animated: true, completion: nil)
    }
    func uploadData(data: Data){
        
        let transferUtility = AWSS3TransferUtility.default()
        let bucket = "myairplanetest"//testをぬいた
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        let key = "\(self.airplaneLabel_text)_\(df.string(from: date)).png"
        let contentType = "image/png"//application->image
        let expression = AWSS3TransferUtilityUploadExpression()
//        expression.progressBlock = {(task, progress) in
//            DispatchQueue.main.async {
//                // アップロード中の処理をここに書く
//                print("upload processing...")
//            }
//        }
        expression.progressBlock = {(task: AWSS3TransferUtilityTask, progress: Progress) in
                print(progress.fractionCompleted)
            }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("upload finished!")
                    // アップロード後の処理をここに書く
                }
            }
        }
        
        
        transferUtility.uploadData(
            data,
            bucket: bucket,
            key: key,
            contentType: contentType,
            expression: expression,
            completionHandler: completionHandler
        ).continueWith { (task) -> Any? in
            if let error = task.error as NSError? {
                print(error.localizedDescription)
            } else {
                print("upload starts")
                // アップロードが始まった時の処理をここに書く
            }
            
            return nil
        }
        
    }
}
