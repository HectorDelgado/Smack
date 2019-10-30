//
//  ChatVC.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/4/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var typingUsersLbl: UILabel!
    
    var isTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AuthService.instance.isLoggedIn {
            messageTextField.isEnabled = false
            messageTextField.isHidden = true
        } else {
            messageTextField.isEnabled = true
            messageTextField.isHidden = false
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        sendBtn.isHidden = true
        typingUsersLbl.text = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatVC.handleTap))
        view.addGestureRecognizer(tap)
        view.bindToKeyboard()

        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        // Listens for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIF_CHANNEL_SELECTED, object: nil)
        
        // Listens for new messages from the server and updates the TableView of messages
        // if the user is on the specified channel and is logged in.
        SocketService.instance.getChatMessage { (newMessage) in
            if newMessage.channelID == MessageService.instance.selectedChannel?.channelID && AuthService.instance.isLoggedIn {
                MessageService.instance.messages.append(newMessage)
                self.tableView.reloadData()
                
                if MessageService.instance.messages.count > 0 {
                    let endPath = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: endPath, at: .bottom, animated: false)
                }
            }
        }
        
        // Listens for users typing on the current channel and notifies the current user whos is typing.
        SocketService.instance.getTypingUsers { (typingUsersDictionary) in
            guard let channelID = MessageService.instance.selectedChannel?.channelID else { return }
            var names = ""
            var numberOfTypers = 0
            
            for (typingUser, channel) in typingUsersDictionary {
                if (typingUser != UserDataService.instance.name && channel == channelID) {
                    if names == "" {
                        names = typingUser
                    } else {
                        names = "\(names), \(typingUser)"
                    }
                    numberOfTypers += 1
                }
            }
            
            if numberOfTypers > 0 && AuthService.instance.isLoggedIn {
                var verb = "is"
                if numberOfTypers > 1 {
                    verb = "are"
                }
                
                self.typingUsersLbl.text = "\(names) \(verb) typing a message"
            } else {
                self.typingUsersLbl.text = ""
            }
        }
        
        // Sends a notification if the user is logged in.
        if AuthService.instance.isLoggedIn {
            AuthService.instance.findUserEmail { (success) in
                NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
            }
        }
    }
    
    /**
     Called when the users data has been updated.
     Attempts to get any stored messages for the user.
     - Parameters notif: Notification that triggered this method.
     */
    @objc func userDataDidChange(_ notif: Notification) {
        if AuthService.instance.isLoggedIn {
            onLoginGetMessages()
        } else {
            channelNameLbl.text = "Please Log In"
            tableView.reloadData()
        }
    }
    
    /**
     Called when a channel has been selected.
     - Parameters notif: Notification that triggered this method.
     */
    @objc func channelSelected(_ notif: Notification) {
        updateWithChannel()
    }
    
    /**
     Called when a user taps out of the typing TextField.
     */
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    /**
     Used to emit 'stopType' and 'startType' events to the server to alert other users on the same channel people are currently typing.
     */
    @IBAction func messageBoxEditing(_ sender: Any) {
        guard let channelId = MessageService.instance.selectedChannel?.channelID else { return }
        if messageTextField.text == "" {
            isTyping = false
            sendBtn.isHidden = true
            SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelId)
        } else {
            if !isTyping {
                sendBtn.isHidden = false
                SocketService.instance.socket.emit("startType", UserDataService.instance.name, channelId)
            }
            isTyping = true
        }
    }
    
    /**
     Sends a message to the server on the current channel.
     */
    @IBAction func sendMessagePressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            guard let channelID = MessageService.instance.selectedChannel?.channelID else { return }
            guard let message = messageTextField.text else { return }
            
            SocketService.instance.addMessage(messageBody: message, userID: UserDataService.instance.id, channelID: channelID) { (success) in
                if success {
                    self.messageTextField.text = ""
                    self.messageTextField.resignFirstResponder()
                    SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelID)
                }
            }
        }
    }
    
    /**
     Updates the selected Channel to display the current channel name and list of messages.
     */
    func updateWithChannel() {
        let channelName = MessageService.instance.selectedChannel?.channelName ?? ""
        channelNameLbl.text = "#\(channelName)"
        getMessages()
    }
    
    /**
     Attempts to retrieve all stored messages for the current user from the server.
     */
    func onLoginGetMessages() {
        MessageService.instance.findAllChannels { (success) in
            if success {
                if (MessageService.instance.channels.count > 0) {
                    MessageService.instance.selectedChannel = MessageService.instance.channels[0]
                    self.updateWithChannel()
                } else {
                    self.channelNameLbl.text = "No Channels yet!"
                }
            }
        }
    }
    
    /**
     Retrieves all messages for the specified channel.
     */
    func getMessages() {
        guard let channelID = MessageService.instance.selectedChannel?.channelID else { return }
        MessageService.instance.findAllMessagesForChannel(channelID: channelID) { (success) in
            if success {
                self.tableView.reloadData()
            }
        }
    }
    
    /**
     Sets the custom cell for the TableView.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
            let message = MessageService.instance.messages[indexPath.row]
            cell.configureCell(message: message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    /**
     Sets the number of sections.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Sets the number of rows in each section.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.messages.count
    }
}
