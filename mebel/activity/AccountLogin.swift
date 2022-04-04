//
//  AccountLogin.swift
//  mebel
//
//  Created by DS on 29.04.2020.
//  Copyright © 2020 DS. All rights reserved.
//

import UIKit
import Alamofire

class AccountLogin: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var activityIcon: UIImageView!
    
    var json:String = "";
    var enableClose: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.layer.cornerRadius = 5
               btnLogin.layer.borderWidth = 0.5
               btnLogin.layer.borderColor = Colors.hexStringToUIColor(hex: Colors.colorBlack).cgColor
               
               btnLogin.layer.cornerRadius = 12
               btnLogin.layer.borderWidth = 1
                btnLogin.layer.borderColor = UIColor.systemTeal.cgColor
               
               let imageView = UIImageView()
               imageView.image = UIImage(named: "sms")
               email.leftViewMode = .always
               email.leftView = imageView
               
               let imageView2 = UIImageView()
               imageView2.image = UIImage(named: "pas")
               password.leftViewMode = .always
               password.leftView = imageView2
        
    }
    
 
    
    @IBAction func auth(_ sender: Any) {
        
        if !Controller.isValidEmail(email: email.text!) {
            DialogMessage.info(viewController:self, message:"Проверьте E-mail!")
            return
        }
        
        if !(password.text!.count > 0) {
            DialogMessage.info(viewController:self, message:"Введите пароль!")
            return
        }
                
        let authItem:AuthItem = AuthItem();
        authItem.email = email.text!;
        authItem.password = password.text!;
        
        do{
            let jsonData = try JSONEncoder().encode(authItem)
            self.json = String(data:jsonData, encoding: String.Encoding.utf8)!
                
            connect()
            
        } catch {
            debugPrint(error)
        }
                
    }
    
    func moveBack(){
        if(enableClose){
            ViewController.nv.popViewController(animated: true)
        }
    }
    
    func connect() {
        
        ProgressBar.show();
        
        let url:String = URLs.sayt + "/" + URLs.api + URLs.authLogin
        
        var headers:HTTPHeaders = []
        headers.add(name:"Accept-Language", value: "*")
        headers.add(name:"Authorization", value: "Basic " + URLs.base64login)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = self.json.data(using: .utf8)
        request.headers = headers
                
        URLs.session.request(request).responseJSON{ response in
            if let status = response.response?.statusCode {
                switch status {
                case 200:
                    do{
                        ViewController.account =  try JSONDecoder().decode(AccountObject.self, from: response.data!)
                        SL.saveAuth(email:self.email.text!, password:self.password.text!)
                        _ = GetMenu(id: nil, fromMenu: false)
                        ViewController.instance?.getBaners()
                        ViewController.updateLimits()
                        ProgressBar.dismiss()
                        self.enableClose = true
                        self.moveBack()
                    } catch {
                        DialogMessage.httpError(viewController: self, data: response.data!)
                    }
                default:
                    DialogMessage.httpError(viewController: self, data: response.data!)
                }
            }
            
            ProgressBar.dismiss()
        }
        
    }
    
}
