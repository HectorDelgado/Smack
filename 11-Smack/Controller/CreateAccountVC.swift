//
//  CreateAccountVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/7/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePressed(_ sender: Any) {
        performSegue(withIdentifier: UNWIND, sender: nil)
    }
    
   

}
