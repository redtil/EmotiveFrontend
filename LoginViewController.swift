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
            //Logged in!
            dismiss(animated: true, completion: nil)
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
