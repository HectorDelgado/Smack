//
//  MessageService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

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
                }
                print(self.channels)
            } else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
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
                }
                
            } else {
                print("Found error in response")
                debugPrint(response.error as Any)
                completion(false)
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    func clearChannels() {
        channels.removeAll()
    }
}
