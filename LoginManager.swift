//
//  LoginManager.swift
//  ImageViewer
//
//  Created by Rediet Tilahun Desta on 1/7/17.
//  Copyright © 2017 Rediet Tilahun Desta. All rights reserved.
//

import Foundation

class LoginManager {
    
    var isLoggedIn = false
    
    func loginWithUsername(username: String, password: String) -> Bool{
        if username != "" && password != ""{
            isLoggedIn = true
            return true
        }else{
            isLoggedIn = false
            return false
        }
        
    }
    static let sharedInstance = LoginManager()
    private init(){
        
    }
}
