//
//  AddChannelVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class AddChannelVC: UIViewController {

    // Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    /**
     Dismisses the current view controller.
     */
    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Attempts to create a new channel on the server.
     */
    @IBAction func createChannelPressed(_ sender: Any) {
        guard let channelName = nameTextField.text , nameTextField.text != "" else { return }
        guard let channelDesc = descriptionTextField.text else { return }
        
        SocketService.instance.addChannel(channelName: channelName, channelDescription: channelDesc) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Channel added")
            } else {
                print("Error creating channel")
            }
        }
    }
    
    /**
     Initializes the states of various views and adds a tap gesture recognizer.
     */
    func setupView() {
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSAttributedString.Key.foregroundColor : PLACEHOLDER_PURPLE])
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "description", attributes: [NSAttributedString.Key.foregroundColor : PLACEHOLDER_PURPLE])
    }
    
    /**
     Dismisses the current view controller.
     */
    @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
