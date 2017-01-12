//
//  RegisterViewController.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 1/7/17.
//  Copyright © 2017 Rediet Tilahun Desta. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet var usernameText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var passwordConfirmText: UITextField!
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        if passwordText.text == passwordConfirmText.text {
            if LoginManager.sharedInstance.loginWithUsername(username:usernameText.text!,password:passwordText.text!){
                let urlString = myUrlFirstPart + "/users/register"
                let myUrl = URL(string:urlString)!;
                let request = NSMutableURLRequest(url:myUrl);
                request.httpMethod = "POST";
                
                let postString = "username=\(usernameText.text!)&password=\(passwordText.text!)";
                request.httpBody = postString.data(using: String.Encoding.utf8)
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                    
                    if error != nil{
                        print("error=\(error)")
                        return
                    }
                    else{
                        self.performSegue(withIdentifier: "registerToLoginSegue", sender: nil)
                    }
                })
                task.resume()

            }
            else{
                
            }
        }else{
            //passwords don't match
        }
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let presentingVC = presentingViewController
        let login = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        dismiss(animated: true) { 
            presentingVC?.present(login!, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
