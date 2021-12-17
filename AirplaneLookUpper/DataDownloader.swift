//
//  DataDownloader.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/12/15.
//

import Foundation
//
// DataDownloader.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import UIKit
import AWSCognito
import AWSCore
import AWSS3

class DataDownloader: NSObject {
    var progress: Int = 0
    let identifier: String
    let stateUpdateHandler: (DataDownloader) -> ()
    var imageData:Data = Data(bytes: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

    var state = TaskState.pending {
        didSet {
            self.stateUpdateHandler(self)
        }
    }
    init(identifier: String, stateUpdateHandler: @escaping (DataDownloader) -> ()) {
        self.identifier = identifier
        self.stateUpdateHandler = stateUpdateHandler
    }
    func startTask(queue: DispatchQueue, group: DispatchGroup, semaphore: DispatchSemaphore, downloadfileName:String)
    {
        queue.async(group: group) { [weak self] in
            group.enter()
            semaphore.wait()
            AWSS3Manager.shared.downloadSingleFileFromAWS(fileName: downloadfileName, progress: { (progress) in
                guard let strongSelf = self else { return }
                strongSelf.state = .inProgess(Float(Double(progress)))
                //print("progress :: ",progress,"for — " , downloadfileName)
            }, completion: { (downloadedData, error) in
                if let receivedData = downloadedData as? Data {
                    guard let strongSelf = self else { return }
                    saveToDocumentDirectory(data: receivedData, fileName: downloadfileName, completionHandler: { (success) in
                        if success {
                            print("success")
                        } else {
                            print("failure")
                        }
                    })
                    strongSelf.imageData=receivedData
                    strongSelf.state = .completed
                } else {
                    print("Error")
                }
            })
            group.leave()
            semaphore.signal()
        }
    }
//    private func startSleep(randomizeTime: Bool = true) {
//        Thread.sleep(forTimeInterval: randomizeTime ? Double(Int.random(in: 1...3)), : 1.0)
//    }
}
enum TaskState {
    case pending
    case inProgess(Float)
    case completed
    var description: String {
        switch self {
        case .pending:
            return "Pending"
        case .inProgess(_):
            return "Downloading"
        case .completed:
            return "Completed"
        }
    }
}
extension Array where Element == DataDownloader {
    func downloadTaskWith(identifier: String) -> DataDownloader? {
        return self.first { $0.identifier == identifier }
    }
    func indexOfTaskWith(identifier: String) -> Int? {
        return self.firstIndex { $0.identifier == identifier }
    }
}
