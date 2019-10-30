//
//  Channel.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/28/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import Foundation

struct Channel : Decodable {
    public private(set) var channelID: String!
    public private(set) var channelName: String!
    public private(set) var channelDescription: String!
}
