//
//  ChannelVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/4/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class ChannelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userImg: CircleImage!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.revealViewController()?.rearViewRevealWidth = self.view.frame.size.width - 60
        
        // Listens for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.userDataDidChange(_:)), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.channelsLoaded(_:)), name: NOTIF_CHANNELS_LOADED, object: nil)
        
        // Attempts to retrieve the information for the current channel.
        SocketService.instance.getChannel { (success) in
            if success {
                self.tableView.reloadData()
            }
        }
        
        // Detects new unread channels
        SocketService.instance.getChatMessage { (newMessage) in
            if newMessage.channelID != MessageService.instance.selectedChannel?.channelID && AuthService.instance.isLoggedIn{
                MessageService.instance.unreadChannels.append(newMessage.channelID)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupUserInfo()
    }
    
    /**
     Displays the AddChannelVC modally to let the user create a new channel if they are logged in.
     */
    @IBAction func addChannelPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            let addChannel = AddChannelVC()
            addChannel.modalPresentationStyle = .fullScreen
            present(addChannel, animated: true, completion: nil)
        }
    }
    
    /**
     If the user is logged in, the ProfileVC is displayed showing their basic info.
     Otherwise a segue is performed to allow the user to login or create a new account.
     */
    @IBAction func loginBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            let profile = ProfileVC()
            profile.modalPresentationStyle = .custom
            present(profile, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: TO_LOGIN, sender: nil)
        }
    }
    
    /**
     Called when a users data has changed.
     - Parameter notif: The notification that triggered this method call.
     */
    @objc func userDataDidChange(_ notif: Notification) {
        setupUserInfo()
    }
    
    /**
     Called when new channels are detected.
     - Parameter notif: The notification that triggered this method call.
     */
    @objc func channelsLoaded(_ notif: Notification) {
        tableView.reloadData()
    }
    
    /**
     If the user is logged in, their avatar is displayed,
     otherwise a blank avatar is displayed.
     */
    func setupUserInfo() {
        if AuthService.instance.isLoggedIn {
            print("User loggin in. updating ui")
            loginBtn.setTitle(UserDataService.instance.name, for: .normal)
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
            userImg.backgroundColor = UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
        } else {
            print("User not loggin in. nothing to change")
            loginBtn.setTitle("Login", for: .normal)
            userImg.image = UIImage(named: "menuProfileIcon")
            userImg.backgroundColor = UIColor.clear
            tableView.reloadData()
        }
    }
    
    /**
     Sets the number of sections.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Sets the number of rows in the section.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.channels.count
    }
    
    /**
     Sets the custom ChannelCell to be displayed in the TableView.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell {
            let mChannel = MessageService.instance.channels[indexPath.row]
            cell.configureCell(channel: mChannel)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    /**
     Toggles the current view controller to hide.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = MessageService.instance.channels[indexPath.row]
        MessageService.instance.selectedChannel = channel
        
        if MessageService.instance.unreadChannels.count > 0 {
            MessageService.instance.unreadChannels = MessageService.instance.unreadChannels.filter {$0 != channel.channelID}
        }
        
        let index = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        
        NotificationCenter.default.post(name: NOTIF_CHANNEL_SELECTED, object: nil)
        
        self.revealViewController()?.revealToggle(animated: true)
    }
}
