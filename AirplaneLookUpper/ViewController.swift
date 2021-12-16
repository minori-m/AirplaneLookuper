//
//  ViewController.swift
//  AirplaneLookUpper
//
//  Created by Minori Manabe on 2021/11/20.
//


import UIKit
import CoreLocation
import SwiftUI
import AVFoundation


class ViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet var label: UILabel!
    @IBOutlet var getLocationButton: UIButton!
    var locationManager: CLLocationManager!
    
    // 測位精度
    let locationAccuracy: [Double] = [
        kCLLocationAccuracyBestForNavigation,
        kCLLocationAccuracyBest,
        kCLLocationAccuracyNearestTenMeters,
        kCLLocationAccuracyHundredMeters,
        kCLLocationAccuracyKilometer,
        kCLLocationAccuracyThreeKilometers
    ]
    var latitude:CLLocationDegrees = 0.0
    var longitude:CLLocationDegrees = 0.0
    var label_text = "initialized"
    
    //カメラセットアップ
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
    //撮影結果
    var resultImage:UIImage? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //location
        // locationManager初期化
        locationManager = CLLocationManager()
        // ユーザーの使用許可を確認
        locationManager.requestWhenInUseAuthorization()
        
        //camera
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        styleCaptureButton()
        
        // 使用許可に対するステータス
        //let status = CLLocationManager.authorizationStatus()
        
        //if status == .authorizedWhenInUse {
        //        if CLLocationManager.locationServicesEnabled(){
        //           // delegateを設定
        //           locationManager.delegate = self
        //           // 測位精度の設定
        //           locationManager.desiredAccuracy = locationAccuracy[1]
        //           // アップデートする距離半径(m)
        //           locationManager.distanceFilter = 10
        //           // 位置情報の取得を開始
        //           locationManager.startUpdatingLocation()
        //        }
        
        
        //flight API
        //let url: URL = URL(string: "https://opensky-network.org/api/states/all?lamin=45.8389&lomin=5.9962&lamax=47.8229&lomax=10.5226")!
        print(self.latitude)
        self.label.text = self.label_text
        
    }
    //for camera
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // シャッターボタンが押された時のアクション
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        
        //airplane
        // delegateを設定
        locationManager.delegate = self
        // 測位精度の設定
        locationManager.desiredAccuracy = locationAccuracy[1]
        // アップデートする距離半径(m)
        locationManager.distanceFilter = 10
        // 位置情報の取得を開始
        locationManager.startUpdatingLocation()
        
//        let storyboard :UIStoryboard = self.storyboard!
//        let changeview = storyboard.instantiateViewController(withIdentifier: "toShootResult")as! ShootResultViewController
        //データ取得に1sかかると考えて待つ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 0.5秒後に実行したい処理
            //self.label?.text = self.label_text
            
            print("into late loop and binmei is \(self.label_text)")
            
//            changeview.airplaneLabel_text = self.label_text
//            print("\(changeview.airplaneLabel_text) has sent")
        }
        
        
        
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .auto
        // カメラの手ぶれ補正
        //settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
        
        
    }
    
//    @IBAction func locationButtonTapped(_ sender:Any){
//        // delegateを設定
//        locationManager.delegate = self
//        // 測位精度の設定
//        locationManager.desiredAccuracy = locationAccuracy[1]
//        // アップデートする距離半径(m)
//        locationManager.distanceFilter = 10
//        // 位置情報の取得を開始
//        locationManager.startUpdatingLocation()
//        //データ取得に1sかかると考えて待つ
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // 0.5秒後に実行したい処理
//            self.label?.text = self.label_text
//
//        }
//
//    }
    enum MyError: Error {
        case BadJSON(String)
    }
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // 最初のデータ
        let location = locations.first
        
        // 緯度
        latitude = (location?.coordinate.latitude)!
        // 経度
        longitude = (location?.coordinate.longitude)!
        
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        let url: URL = URL(string: "https://opensky-network.org/api/states/all?lamin=\(self.latitude-2.0)&lomin=\(self.longitude-2.0)&lamax=\(self.latitude+2.0)&lomax=\(self.longitude+2.0)")!
        let task: URLSessionTask  = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                // JSONシリアライズ
                let raw_data = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                let each_flignt = try raw_data["states"]! as! NSArray
                
                //                print(self.latitude)
                //                print(type(of:raw_data["states"]))
                //                print(raw_data["states"])
                //                print(raw_data)
                print(url)
                //                print(each_flignt)
                var shortest_distance = 100000000.0
                var shortest_flight = ""
                for this_flight in each_flignt {
                    let flight = this_flight as! NSArray
                    let flight_point:CLLocation = CLLocation(latitude: flight[6] as! CLLocationDegrees, longitude: flight[5] as! CLLocationDegrees)
                    let distance = flight_point.distance(from: location!)
                    print("distance is \(distance)")
                    if  distance < shortest_distance {
                        shortest_distance = distance
                        shortest_flight = flight[1] as! String
                    }
                }
                print("shortest is \(shortest_flight)")
                
                
//                let first_flight = try each_flignt[1] as! NSArray
//                //                print(first_flight)
//                print(first_flight[1])
                //self.label_text = first_flight[1] as! String //1:便名, 5:latitude, 6:longtitude,7:altitude(高度)
                self.label_text = shortest_flight //1:便名, 5:latitude, 6:longtitude,7:altitude(高度)
                
                //label.text = first_flight as! String
                print("label_text is  \(self.label_text)")
                
            }
            catch {
                print(error)
            }
        })
        task.resume()
        
    }
}

//MARK: AVCapturePhotoCaptureDelegateデリゲートメソッド
extension ViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
        }
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            return
        }
        //撮影結果を保持
        resultImage = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //撮影結果画面へ遷移
            self.performSegue(withIdentifier: "toShootResult", sender: nil)
        }
    }
    
}


extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShootResult"{
            let shootResultViewController = segue.destination as! ShootResultViewController
            shootResultViewController.resultImage = resultImage
            
            shootResultViewController.airplaneLabel_text = self.label_text
            print("set airplane num as \(self.label_text)")
            print("send \(shootResultViewController.airplaneLabel_text)")
            
        }
    }
    
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
}

