//
//  LoginViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 1/7/17.
//  Copyright © 2017 Rediet Tilahun Desta. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!

    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if LoginManager.sharedInstance.loginWithUsername(username: usernameText.text!,
                                                         password:passwordText.text!){
            let urlString = myUrlFirstPart + "/users/login"
            let myUrl = URL(string:urlString)!
            let request = NSMutableURLRequest(url:myUrl);
            request.httpMethod = "POST";
            
            let postString = "username=\(usernameText.text!)&password=\(passwordText.text!)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if let data = data {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        if let parseJSON = json {
                            print("I am in login Button Tapped")
                            let resultValue = parseJSON["status"] as! String
                            print(resultValue)
                            if resultValue == "success" {
                                print("I am inside login success")
//                                self.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "loginMainViewSegue", sender: nil)
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
            
        } else{
            //Log in failed
        }
        
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        //Dismiss this view
        let presentingVC = presentingViewController
        //Present registerViewController
        let register = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController")
        dismiss(animated: true) {
            presentingVC?.present(register!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
