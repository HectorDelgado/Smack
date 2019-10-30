//
//  SocketService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//
//  Singleton service that acts as a socket to listen/transmit channels and messages to/from the server.
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
    
    /**
     Creates a new channel on the server by emitting the 'newChannel' event.
     - Parameter channelName: Name of the channel to create.
     - Parameter channelDescription: Description for the channel to be created.
     - Parameter completion: Closure that accepts a boolean as its parameter (true for success)
     */
    func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
        socket.emit("newChannel", channelName, channelDescription)
        completion(true)
    }
    
    /**
     Retrieves any new channels created on the server by listening for the 'channelCreated' event and adds it to the channels array.
     - Parameter completion: Closure that accepts a boolean as its parameter (true for success)
     */
    func getChannel(completion: @escaping CompletionHandler) {
        socket.on("channelCreated") { (dataReceived, ack) in
            guard let channelId = dataReceived[2] as? String else { return }
            guard let channelName = dataReceived[0] as? String else { return }
            guard let channelDesc = dataReceived[1] as? String else { return }
            
            print("Info: \(channelId)\(channelName)\(channelDesc)")
            
            let newChannel = Channel(channelID: channelId, channelName: channelName, channelDescription: channelDesc)
            MessageService.instance.channels.append(newChannel)
            completion(true)
        }
    }
    
    /**
     Creates a new message on the server by emitting a 'newMessage' event.
     - Parameter messageBody: Body of the message to send.
     - Parameter userID: Unique identifier associated with the user who is sending the message.
     - Parameter channelID: Unique identifier associated with the channel where the message was sent from.
     - Parameter completion: Closure that accepts a boolean as its parameter (true for success)
     */
    func addMessage(messageBody: String, userID: String, channelID: String, completion: @escaping CompletionHandler) {
        let user =  UserDataService.instance
        socket.emit("newMessage", messageBody, userID, channelID, user.name, user.avatarName, user.avatarColor)
        completion(true)
    }
    
    /**
     Retrieves any new messages created on the server by listening for the 'messageCreated' event.
     - Parameter completion: Closure that accepts the new Message as its parameter.
     */
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
    
    /**
     Retrieves a dictionary of the  users that is currently typing in the current channel.
     - Parameter completionHandler: Closure that accepts the Dictionary associated with the typing users.
     */
    func getTypingUsers(_ completionHandler: @escaping (_ typingUser: [String: String]) -> Void) {
        socket.on("userTypingUpdate") { (dataReceived, ack) in
            guard let typingUsers = dataReceived[0] as? [String: String] else { return }
            completionHandler(typingUsers)
        }
    }
}
