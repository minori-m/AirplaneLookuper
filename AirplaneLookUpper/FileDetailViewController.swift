//
// FileDetailViewController.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import UIKit
import QuickLook // For QLPreviewController Use //
class FileDetailViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    //class FileDetailViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    var fileURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.loadDocUsingDocInteractionController()
        self.loadDocUsingQLPreview()
    }
    /*
     func loadDocUsingDocInteractionController() {
     guard let url = self.fileURL else {
     fatalError(“Could not load file”)
     }
     let docInteractionController = UIDocumentInteractionController(url: url)
     docInteractionController.delegate = self
     docInteractionController.presentPreview(animated: true)
     }
     func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController{
     return self
     }
     public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
     self.navigationController!.popViewController(animated: true)
     }
     */
    func loadDocUsingQLPreview() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        self.present(previewController, animated: true, completion: nil)
    }
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = self.fileURL else {
            fatalError("Could not load file")
        }
        return url as QLPreviewItem
    }
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.navigationController!.popViewController(animated: true)
    }
}
