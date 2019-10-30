//
//  Message.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/29/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//
//  Data model associated with a specific Message.

import Foundation

struct Message {
    public private(set) var message: String!
    public private(set) var userName: String!
    public private(set) var channelID: String!
    public private(set) var userAvatar: String!
    public private(set) var userAvatarColor: String!
    public private(set) var id: String!
    public private(set) var timeStamp: String!
}
