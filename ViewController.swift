//
//  ViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 12/28/16.
//  Copyright © 2016 Rediet Tilahun Desta. All rights reserved.
//

import UIKit
import AVFoundation

//var myUrlFirstPart = "https://emotivebackend-154820.appspot.com"
//var myUrlFirstPart = "http://localhost:3000"
var myUrlFirstPart = "http://10.192.233.92:3000"

class ViewController: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var timer: Timer!
    var startCapturing = false
    var seconds = 10
    
    
    
    @IBOutlet var imageDesriber: UITextView!
    
    @IBAction func uploadAlbumButton(_ sender: UIButton) {
        print("performing segue to upload albums");
        self.performSegue(withIdentifier: "uploadAlbumSegue", sender: nil)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        self.timer.invalidate()
        self.timer = nil
//        self.dismiss(animated: true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: {})
        
//        navigationController?.setViewControllers(viewControllers!, animated: true)
//        let urlString = myUrlFirstPart + "/users/logout"
//        let myUrl = URL(string: urlString)!
//        let request = NSMutableURLRequest(url:myUrl);
//        request.httpMethod = "POST";
//        
//        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
//            
//            if let data = data {
//                do{
//                    let json = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
//                    if let parseJSON = json {
//                        let resultValue = parseJSON["status"] as! String
////                        print(resultValue)
//                        if resultValue == "success" {
//                            print("I am inside success logout")
//                            self.timer.invalidate()
//                            self.timer = nil
////                            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
//                        }
//                    }
//                    
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
//            
//        })
//        task.resume()
    }
    
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pickedImage: UIImageView!
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    var arrayPosts = [String]()
    var arrayLinks = [String]()
    var arrayConditions = [String]()
    var arrayIDs = [String]()
    var count = 0
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        print(url)
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func decrementSecs(){
        print("seconds is: ")
        print(self.seconds)
        if self.seconds >= 1 && self.seconds != 5{
            self.seconds = self.seconds-1
        }
        else if self.seconds == 5{
            self.startCapturing = true
            self.seconds = self.seconds-1

        }
        else{
            self.sendSessionDataToBackEnd()
            let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(respond))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            
            self.respond(gesture: swipeRight)
        }
    }
    
    
    //begin photo capturing session for AVcapture module
    func beginSession(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        }catch{
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        {
            self.previewLayer = previewLayer
//            self.view.layer.addSublayer(self.previewLayer)
//            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput){
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label:"com.ImageViewer.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
        
    }
    
    //delegate function called continuously because photo capturing session has begun
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if startCapturing{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.capturedPhoto = self.getImageFromSamplBuffer(buffer: sampleBuffer)
            self.startCapturing = false
//            if self.capturedPhoto != nil{
//                print("captureOutput image buffer received")
//                DispatchQueue.main.async{
//                    let photoVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier:"ImageViewerVC") as! ImageViewerController
//                    photoVC.takenPhoto = self.capturedPhoto
//                    print("captureOutput image ready to be displayed")
//                    self.startCapturing = false
//                    self.present(photoVC, animated:true, completion:nil)
//                }
//            }
        }
    }
    
    //helper function for captureOutput
    func getImageFromSamplBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x:0, y:0, width:CVPixelBufferGetWidth(pixelBuffer), height:CVPixelBufferGetHeight(pixelBuffer))
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale:UIScreen.main.scale, orientation:.right)
            }
        }
        
        return nil

    }
    
    //using AVFoundation to take pictures every few seconds: work in progress
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices{
            captureDevice = availableDevices.first
            beginSession()
            
        }
    }
    
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.decrementSecs), userInfo: nil, repeats: true)
            }
        }
    }
    
    func sendSessionDataToBackEnd(){
        self.timer.invalidate()
        let urlString = myUrlFirstPart + "/users/processSessionData"
        let myUrl = URL(string: urlString)!
        let request = NSMutableURLRequest(url:myUrl);
        request.httpMethod = "POST";
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        print("seconds: ")
        print(self.seconds)
        let timeSpent:Double = Double(10 - self.seconds)
        print("timeSpent: ")
        print(timeSpent)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.capturedPhoto == nil{
            print("capturedPhoto is actually nil")
        }
//        DispatchQueue.main.async{
//            let photoVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier:"ImageViewerVC") as! ImageViewerController
//            photoVC.takenPhoto = appDelegate.capturedPhoto
//            print("displaying capturedImage at the end of a session!")
//            self.present(photoVC, animated:true, completion:nil)
//            
//        }
        
        
//        let imageData = UIImageJPEGRepresentation(appDelegate.capturedPhoto!, 1)
//        jsonObject.setValue(timeSpent, forKey: "timeSpent")
//        jsonObject.setValue(imageData?.base64EncodedString(), forKey: "imageData")
//
//        
//        let jsonData: NSData
//        
//        do {
//            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
//            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
//            print("json string = \(jsonString)")
//            request.addValue("/application/json",forHTTPHeaderField: "Content-Type")
//            request.httpBody = jsonData as Data
//        } catch _ {
//            print ("JSON Failure")
//        }
//        
//        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
//            
//            if let data = data {
//                do{
//                    let responseString = NSString(data: data, encoding: 8)
//                    print("responseString = \(responseString)")
//                    
//                } catch let error as NSError {
//                    print("I am in the first error")
//                    print(error.localizedDescription)
//                }
//            } else if let error = error {
//                print("I am in the second error")
//                print(error.localizedDescription)
//            }
//            
//        })
//        task.resume()
    }
    
    //respond to swipe right or left
    func respond(gesture: UISwipeGestureRecognizer){
        let urlString = myUrlFirstPart + "/get-data";
        let url = URL(string: urlString)!
        print("right before sendSessionDataToBackEnd seconds: ")
        print(self.seconds)
        //before setting seconds back to 300 first calculate the time spent before swipe and send to the backend
        
        self.timer.invalidate()
        self.timer = nil
        
        self.seconds = 10
        print("I am in RESPOND to gesture")
        
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                print("I am in RESPOND2")
                let urls = json?["urls"] as! [AnyObject]
                var cnt = 0
                for urlObj in urls{
                    let url = urlObj["url"] as! String
                    
                    if let checkedUrl = URL(string: url) {
//                        print("I am in RESPOND3")
//                        print(cnt)
//                        print(self.count)
                        if cnt == self.count{
                            self.count = self.count + 1
                            self.imageView.contentMode = .scaleAspectFit
                            self.downloadImage(url: checkedUrl)
                            break
                        }
                    }
                    cnt = cnt + 1
                }
                print("GestureResponse. The image will continue downloading in the background and it will be loaded when it ends.")
            } catch {
                
                print("error in JSONSerialization")
                
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        if self.view.window != nil{
            print("TRUE !!!!!")
        }
//        if self.view.window != nil {
//            print("TRUE222!!!!!")
//        }
//            
//        if self.isViewLoaded && (self.view.window != nil) {
//            // viewController is visible
//        }
            
        else{
            super.viewDidLoad()
            prepareCamera()
            

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        if LoginManager.sharedInstance.isLoggedIn == false {
//            //            perform(#selector(self.presentExampleController), with: nil, afterDelay: 0)
//            
//            print("performing segue");
//            self.performSegue(withIdentifier: "isNotLoggedInSegue", sender: nil)
//            
//        }
//        else{
        
            let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(respond))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(respond))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            
            view.addGestureRecognizer(swipeRight)
            
            
            view.addGestureRecognizer(swipeLeft)
            
            let urlString = myUrlFirstPart + "/get-data"
            let url = URL(string: urlString)!
            print("I am in RESPOND main view controller")
            
            //camera is turned on
            //            startCameraCaptureProcess()
            
            getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                print("I am in getDataFromUrl")
                do {
                    let json = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                    let urls = json?["urls"] as! [AnyObject]
                    for urlObj in urls{
                        let url = urlObj["url"] as! String
                        if let checkedUrl = URL(string: url) {
                            if self.count == 0{
                                self.count = self.count + 1
                                self.imageView.contentMode = .scaleAspectFit
                                self.downloadImage(url: checkedUrl)
                                break
                            }
                        }
                        
                    }
                    print("viewDidLoad. The image will continue downloading in the background and it will be loaded when it ends.")
                } catch {
                    
                    print("error in JSONSerialization")
                }
            }

//        }
        
    }
    
}
