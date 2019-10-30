//
//  LoginVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/6/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        
        guard let userEmail = emailTextField.text , emailTextField.text != "" else { return }
        guard let userPassword = passwordTextField.text , passwordTextField.text != "" else { return }
        
        AuthService.instance.loginUser(email: userEmail, password: userPassword) { (success) in
            if (success) {
                print("User Loggin in Successfully")
                AuthService.instance.findUserEmail { (findUserIsSuccess) in
                    if findUserIsSuccess {
                        NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                print("Error Logging in")
            }
        }
    }
    @IBAction func createAccountBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_CREATE_ACCOUNT, sender: nil)
    }
    
    func setupView() {
        spinner.isHidden = true
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
    }
}
