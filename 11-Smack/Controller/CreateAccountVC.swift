//
//  CreateAccountVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/7/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameField : UITextField!
    @IBOutlet weak var emailField : UITextField!
    @IBOutlet weak var passwordField : UITextField!
    @IBOutlet weak var userImg : UIImageView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var avatarName = "defaultUser"
    var avatarColor = "[0.5, 0.5, 0.5, 1]"
    var bgColor : UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    /**
     Sets the avatar image if they have returned from the AvatarPickerVC and chosen an avatar.
     */
    override func viewDidAppear(_ animated: Bool) {
        if UserDataService.instance.avatarName != "" {
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
            avatarName = UserDataService.instance.avatarName
            
            if avatarName.contains("light") && bgColor == nil {
                userImg.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    /**
     Initializes the states of various views and adds a tap gesture recognizer.
     */
    func setupView() {
        activitySpinner.isHidden = true
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
        emailField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
        passwordField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: PLACEHOLDER_PURPLE])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateAccountVC.handlTap))
        view.addGestureRecognizer(tap)
    }
    
    /**
     Handles tap events.
     */
    @objc func handlTap() {
        view.endEditing(true)
    }
    
    /**
     Performs an unwind segue when the user pressed the close button.
     */
    @IBAction func closePressed(_ sender: Any) {
        performSegue(withIdentifier: UNWIND, sender: nil)
    }
    
    /**
     Performs a segue to the AvatarPickerVC.
     */
    @IBAction func chooseAvatarPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_AVATAR_PICKER, sender: nil)
    }
    
    /**
     Generates and sets a random UIColor for the userImg background.
     */
    @IBAction func generateBGColorPressed(_ sender: Any) {
        let r = CGFloat(arc4random_uniform(255)) / 255
        let g = CGFloat(arc4random_uniform(255)) / 255
        let b = CGFloat(arc4random_uniform(255)) / 255
        
        bgColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        avatarColor = "[\(r), \(g), \(b), 1]"
        
        UIView.animate(withDuration: 0.2) {
            self.userImg.backgroundColor = self.bgColor
        }
    }
    
    /**
     Attempts to register, login, and create a new user with the specified username, email, and password.
     */
    @IBAction func createAccountPressed(_ sender: Any) {
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
        
        guard let username = usernameField.text , emailField.text != "" else { return }
        guard let email = emailField.text , emailField.text != "" else { return }
        guard let pass = passwordField.text, passwordField.text != "" else { return }
        
        // Attempts to register the user
        AuthService.instance.registerUser(email: email, password: pass) { (isRegistered) in
            if isRegistered {
                print("Registered user!")
                
                // Attempts to login the newly created user
                AuthService.instance.loginUser(email: email, password: pass) { (isLoggedIn) in
                    if isLoggedIn {
                        print("logged in user!", AuthService.instance.authToken)
                        
                        // Attempts to create a new user with the new info.
                        AuthService.instance.createUser(name: username, email: email, avatarName: self.avatarName, avatarColor: self.avatarColor) { (userCreated) in
                            if (userCreated) {
                                print("Created new user!")
                                self.activitySpinner.isHidden = true
                                self.activitySpinner.stopAnimating()
                                AuthService.instance.isLoggedIn = true
                                self.performSegue(withIdentifier: UNWIND, sender: nil)
                                NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
