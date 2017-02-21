//
//  ViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 12/28/16.
//  Copyright © 2016 Rediet Tilahun Desta. All rights reserved.
//

import UIKit

var myUrlFirstPart = "https://emotivebackend-154820.appspot.com"
//var myUrlFirstPart = "http://localhost:3000"

class ViewController: UIViewController {
    
    var timer: Timer!
    
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
        
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
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

