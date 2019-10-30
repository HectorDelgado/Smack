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
    
    /**
     Dismisses the current view controller.
     */
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Attempts to login a user using the email/password entered.
     A notification is sent if they successfully login.
     */
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
    
    /**
     Performs a segue to the CreateAccountVC.
     */
    @IBAction func createAccountBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_CREATE_ACCOUNT, sender: nil)
    }
    
    /**
     Sets up the basic state of various views.
     */
    func setupView() {
        spinner.isHidden = true
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
    }
}
