//
//  ViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 12/28/16.
//  Copyright © 2016 Rediet Tilahun Desta. All rights reserved.
//

import UIKit
import AVFoundation

var myUrlFirstPart = "https://emotivebackend-154820.appspot.com"
//var myUrlFirstPart = "http://localhost:3000"

class ViewController: UIViewController,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var timer: Timer!
    var startCapturing = false
    
    
    @IBOutlet var imageDesriber: UITextView!
    
    @IBAction func uploadAlbumButton(_ sender: UIButton) {
        print("performing segue to upload albums");
        self.performSegue(withIdentifier: "uploadAlbumSegue", sender: nil)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let urlString = myUrlFirstPart + "/users/logout"
        let myUrl = URL(string: urlString)!
        let request = NSMutableURLRequest(url:myUrl);
        request.httpMethod = "POST";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    if let parseJSON = json {
                        let resultValue = parseJSON["status"] as! String
                        print(resultValue)
                        if resultValue == "success" {
                            print("I am inside success logout")
                            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
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
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    func runTimedCode(){
        startCapturing = true
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
            print("AV session has begun!")
        }
        
    }
    
    //delegate function called continuously because photo capturing session has begun
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("captureOutput called")
        if startCapturing{
        if let image = self.getImageFromSamplBuffer(buffer: sampleBuffer){
            print("captureOutput image buffer received")
            DispatchQueue.main.async{
                let photoVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier:"ImageViewerVC") as! ImageViewerController
                photoVC.takenPhoto = image
                print("captureOutput image ready to be displayed")
                self.startCapturing = false
                self.present(photoVC, animated:true, completion:nil)

            }
        }
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
    
//    //using imageView to take pictures every few seconds: doesn't work
//    func startCameraCaptureProcess(){
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//            imagePicker.allowsEditing = false
//            imagePicker.cameraDevice = .rear
//            self.present(imagePicker,animated: true, completion: nil)
//            print("I am in startCameraCaptureProcess")
//        }
//        
//        //code to save image
////        let imageData = UIImageJPEGRepresentation(pickedImage.image!, 0.6)
////        let compressedJPEGImage = UIImage(data: imageData!)
////        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
//    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!) {
//        pickedImage.image = image
//    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: false)
            }
        }
    }
    
    //respond to swipe right or left
    func respond(gesture: UISwipeGestureRecognizer){
        let urlString = myUrlFirstPart + "/get-data";
        let url = URL(string: urlString)!
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
                        print("I am in RESPOND3")
                        print(cnt)
                        print(self.count)
                        if cnt == self.count{
                            self.count = self.count + 1
                            self.imageView.contentMode = .scaleAspectFit
                            self.downloadImage(url: checkedUrl)
                            break
                        }
                    }
                    cnt = cnt + 1
                }
                print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
            } catch {
                
                print("error in JSONSerialization")
                
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if LoginManager.sharedInstance.isLoggedIn == false {
            //            perform(#selector(self.presentExampleController), with: nil, afterDelay: 0)
            
            print("performing segue");
            self.performSegue(withIdentifier: "isNotLoggedInSegue", sender: nil)
            
        }else{
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(respond))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(respond))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            view.addGestureRecognizer(swipeLeft)
            
            let urlString = myUrlFirstPart + "/get-data"
            let url = URL(string: urlString)!
            print("I am in RESPOND main view controller")
            
            //camera is turned on
//            startCameraCaptureProcess()
            prepareCamera()
            
            getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
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
                    print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
                } catch {
                    
                    print("error in JSONSerialization")
                }
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
