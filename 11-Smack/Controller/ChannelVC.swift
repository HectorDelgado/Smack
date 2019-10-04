//
//  ChannelVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/4/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class ChannelVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.revealViewController()?.rearViewRevealWidth = self.view.frame.size.width - 60
    }
    

}
