//
//  ViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 12/28/16.
//  Copyright © 2016 Rediet Tilahun Desta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var arrayPosts = [String]()
    var arrayLinks = [String]()
    var arrayConditions = [String]()
    var arrayIDs = [String]()
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func presentExampleController() {
        let login = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        present(login!, animated: true, completion: nil)
    }
    
    func checkLogin(){
        if LoginManager.sharedInstance.isLoggedIn == false {
            perform(#selector(self.presentExampleController), with: nil, afterDelay: 0)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLogin()
        
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "http://localhost:3000/get-data")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        //Implement your logic
                    let urls = json?["urls"] as! [AnyObject]
                    for urlObj in urls{
                        let url = urlObj["url"] as! String
                    
                        if let checkedUrl = URL(string: url) {
                            self.imageView.contentMode = .scaleAspectFit
                            self.downloadImage(url: checkedUrl)
                        }
                    }
                        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
                        
                    
                    
                } catch {
                    
                    print("error in JSONSerialization")
                    
                }
                
                
            }
            
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

