//
// AWSS3FileManager.swift
// AWSS3Integration
//
// Created by Soham Paul
// Copyright © 2019 Personal. All rights reserved.
//
import UIKit
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
func saveFileAtDocumentsDirectory(data:Data, fileName:String){
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
    // print(paths)
    fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
}
func filesInDocumentsDirectory(){
    let fm = FileManager.default
    let path = Bundle.main.resourcePath!
    do {
        let items = try fm.contentsOfDirectory(atPath: path)
        for item in items {
            print("Found \(item)")
        }
    } catch {
        // failed to read directory — bad permissions, perhaps?
    }
}
func createAWSDocumentsDirectory(){
    let fileManager = FileManager.default
    let newDir = getDocumentsDirectory().appendingPathComponent("AWSDirectory").path
    do {
        try fileManager.createDirectory(atPath: newDir, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}
func getAWSDocumentsDirectoryUrl() -> URL {
    return getDocumentsDirectory().appendingPathComponent("AWSDirectory")
}
func saveFileAtAWSDocumentsDirectory(data:Data, fileName:String, completionHandler: @escaping CompletionHandler){
    let fileManager = FileManager.default
    let paths = getAWSDocumentsDirectoryUrl().appendingPathComponent(fileName).path
    print("paths: ", paths)
    //fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
    if(!fileManager.fileExists(atPath:paths)){
        fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
        completionHandler(true)
    }else{
        print("File is already created")
        completionHandler(true)
    }
}
func getFilesPathFromAWSDocumentsDirectory() -> Array<String>{
    let fileManager = FileManager.default
    do {
        let filelist = try fileManager.contentsOfDirectory(atPath:getAWSDocumentsDirectoryUrl().path)
        for filename in filelist {
            print(filename)
        }
        return filelist
    } catch let error {
        print("Error: \(error.localizedDescription)")
    }
    return []
}
func getFileType(fileName:String) -> String{
    let fileType = fileName.fromStringToEnd(".")
    // print("fileType ", fileType as Any)
    if (fileType == "txt"){
        return "txt"
    }
    else if (fileType == "pdf"){
        return "pdf"
    }
    else if (fileType == "doc"){
        return "doc"
    }
    else if (fileType == "xls"){
        return "xls"
    }
    else if (fileType == "mp3"){
        return "mp3"
    }else if (fileType == "mp4"){
        return "mp4"
    }else if (fileType == "jpeg"){
        return "jpeg"
    }else if (fileType == "csv"){
        return "csv"
    }else if (fileType == "ppt"){
        return "ppt"
    }
    return ""
}
func getCellImage(fileName:String) -> String {
    let fileType = fileName.fromStringToEnd(".")
    // print("fileType ", fileType as Any)
    if (fileType == "txt"){
        return "text_icon.png"
    }
    else if (fileType == "pdf"){
        return "pdf_icon.png"
    }
    else if (fileType == "doc"){
        return "doc_icon.png"
    }
    else if (fileType == "xls"){
        return "xls_icon.png"
    }
    else if (fileType == "mp3"){
        return "audio_icon.png"
    }else if (fileType == "mp4"){
        return "video_icon.png"
    }else if (fileType == "jpeg"){
        return "image_icon.png"
    }else if (fileType == "csv"){
        return "csv_icon.png"
    }else if (fileType == "ppt"){
        return "powerPoint_icon"
    }
    return "blank_icon.png"
}
func saveToDocumentDirectory(data : Any, fileName:String, completionHandler: @escaping CompletionHandler ){
    print(getDocumentsDirectory())
    let fileType = fileName.fromStringToEnd(".")
    // print("fileType ", fileType as Any)
    if (fileType == "txt"){
        //saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: "apple.txt")
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName) { (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "pdf"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "doc"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "xls"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "mp3"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "mp4"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "jpeg"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "png"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("pngsuccess")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "csv"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
                completionHandler(false)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
    else if (fileType == "ppt"){
        saveFileAtAWSDocumentsDirectory(data: data as! Data, fileName: fileName){ (success) in
            if success {
                print("success")
                completionHandler(true)
            } else {
                print("failure")
                completionHandler(false)
            }
        }}
}
