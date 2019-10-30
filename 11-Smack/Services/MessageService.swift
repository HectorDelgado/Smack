//
//  MessageService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//
//  Singleton service used to retrieve new channels and messages.

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    // Create singleton
    static let instance = MessageService()
    
    var channels = [Channel]()
    var messages = [Message]()
    var unreadChannels = [String]()
    var selectedChannel: Channel?
    
    /**
     Attempts to retrieve all the channels associated with the current user.
     Stores any channels found in the channels array.
     - Parameter completion:Closure that accepts a boolean as its parameter (true for success, false for failure)
     */
    func findAllChannels(completion: @escaping CompletionHandler) {
        AF.request(URL_GET_CHANNELS, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.error == nil {
                guard let responseData = response.data else { return }
                
                do {
                    if let json = try JSON(data: responseData).array {
                        for item in json {
                            let id = item["_id"].stringValue
                            let name = item["name"].stringValue
                            let description = item["description"].stringValue
                            let channel = Channel(channelID: id, channelName: name, channelDescription: description)
                            
                            self.channels.append(channel)
                        }
                        NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                        completion(true)
                    }
                } catch let error {
                    print(error)
                    completion(false)
                }
            } else {
                debugPrint(response.error as Any)
                completion(false)
            }
        }
    }
    
    /**
     Attempts to retrieve all the messages associated with the specified channel ID.
     Stores any messages for that channel in the messages array.
     - Parameter channelID: The unique ID associated with a specific channel.
     - Parameter completion: Closure that accepts a boolean as its parameter (true for success, false for failure)
     */
    func findAllMessagesForChannel(channelID: String, completion: @escaping CompletionHandler) {
        let requestURL = "\(URL_GET_MESSAGES)\(channelID)"
        AF.request(requestURL, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.error == nil {
                self.clearMessages()
                guard let responseData = response.data else { return }
                
                do {
                    if let jsonData = try JSON(data: responseData).array {
                        for item in jsonData {
                            let messageBody = item["messageBody"].stringValue
                            let channelID = item["channelId"].stringValue
                            let id = item["_id"].stringValue
                            let userName = item["userName"].stringValue
                            let userAvatar = item["userAvatar"].stringValue
                            let userAvatarColor = item["userAvatarColor"].stringValue
                            let timeStamp = item["timeStamp"].stringValue
                            
                            let newMessage = Message(message: messageBody, userName: userName, channelID: channelID, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                            
                            self.messages.append(newMessage)
                        }
                        completion(true)
                    }
                } catch let error {
                    print("Error converting data to JSON")
                    debugPrint(error)
                    completion(false)
                }
            } else {
                print("Found error in response")
                debugPrint(response.error as Any)
                completion(false)
            }
        }
    }
    
    /**
     Clears all data from the messages array
     */
    func clearMessages() {
        messages.removeAll()
    }
    
    /**
     Clears all data from the channels array
     */
    func clearChannels() {
        channels.removeAll()
    }
}
