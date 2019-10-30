//
//  SocketService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import UIKit
import SocketIO

class SocketService: NSObject {
    static let instance = SocketService()
    
    let manager: SocketManager
    let socket: SocketIOClient
    
    override init() {
        self.manager = SocketManager(socketURL: URL(string: BASE_URL)!)
        self.socket = manager.defaultSocket
        
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
        socket.emit("newChannel", channelName, channelDescription)
        print("Connection Status when adding channel: \(socket.status.active)")
        completion(true)
    }
    
    func getChannel(completion: @escaping CompletionHandler) {
        
        socket.on("channelCreated") { (dataReceived, ack) in
            
            print("Attempting to get channel info")
            guard let channelId = dataReceived[2] as? String else { return }
            guard let channelName = dataReceived[0] as? String else { return }
            guard let channelDesc = dataReceived[1] as? String else { return }
            
            print("Info: \(channelId)\(channelName)\(channelDesc)")
            
            let newChannel = Channel(channelID: channelId, channelName: channelName, channelDescription: channelDesc)
            MessageService.instance.channels.append(newChannel)
            completion(true)
        }
    }
    
    func addMessage(messageBody: String, userID: String, channelID: String, completion: @escaping CompletionHandler) {
        let user =  UserDataService.instance
        socket.emit("newMessage", messageBody, userID, channelID, user.name, user.avatarName, user.avatarColor)
        completion(true)
    }
    
    func getChatMessage(completion: @escaping (_ newMessage: Message) -> Void) {
        socket.on("messageCreated") { (dataReceived, ack) in
            guard let msgBody = dataReceived[0] as? String else { return }
            guard let channelID = dataReceived[2] as? String else { return }
            guard let userName = dataReceived[3] as? String else { return }
            guard let userAvatar = dataReceived[4] as? String else { return }
            guard let userAvatarColor = dataReceived[5] as? String else { return }
            guard let id = dataReceived[6] as? String else { return }
            guard let timeStamp = dataReceived[7] as? String else { return }
            
            let newMessage = Message(message: msgBody, userName: userName, channelID: channelID, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
            
            completion(newMessage)
        }
    }
    
    func getTypingUsers(_ completionHandler: @escaping (_ typingUser: [String: String]) -> Void) {
        socket.on("userTypingUpdate") { (dataReceived, ack) in
            guard let typingUsers = dataReceived[0] as? [String: String] else { return }
            completionHandler(typingUsers)
        }
    }
}
