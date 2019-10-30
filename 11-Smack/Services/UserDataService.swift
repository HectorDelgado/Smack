//
//  UserDataService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/8/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import Foundation

class UserDataService {
    static let instance = UserDataService()
    
    public private(set) var id = ""
    public private(set) var avatarColor = ""
    public private(set) var avatarName = ""
    public private(set) var email = ""
    public private(set) var name = ""
    
    func setUserData(id: String, avatarColor: String, avatarName: String, email: String, name: String) {
        self.id = id
        self.avatarColor = avatarColor
        self.avatarName = avatarName
        self.email = email
        self.name = name
    }
    
    func setAvatarName(avatarName: String) {
        self.avatarName = avatarName
    }
    
    func returnUIColor(components: String) -> UIColor {
        let scanner = Scanner(string: components)
        let skippedCharacters = CharacterSet(charactersIn: "[], ")
        let seperator = CharacterSet(charactersIn: ",")
        
        scanner.charactersToBeSkipped = skippedCharacters
        
        var r, b, g, a : NSString?
        
        scanner.scanUpToCharacters(from: seperator, into: &r)
        scanner.scanUpToCharacters(from: seperator, into: &g)
        scanner.scanUpToCharacters(from: seperator, into: &b)
        scanner.scanUpToCharacters(from: seperator, into: &a)
    
        
        let defaultColor = UIColor.lightGray
        
        // Unwrap optional strings
        guard let rUnwrapped = r else { return defaultColor }
        guard let gUnwrapped = g else { return defaultColor }
        guard let bUnwrapped = b else { return defaultColor }
        guard let aUnwrapped = a else { return defaultColor }
        
        // Convert string to double to CGFloat values
        let rFloat = CGFloat(rUnwrapped.doubleValue)
        let gFloat = CGFloat(gUnwrapped.doubleValue)
        let bFloat = CGFloat(bUnwrapped.doubleValue)
        let aFloat = CGFloat(aUnwrapped.doubleValue)
        
        let newUIColor = UIColor(red: rFloat, green: gFloat, blue: bFloat, alpha: aFloat)
        return newUIColor
    }
    
    func logoutUser() {
        id = ""
        avatarName = ""
        avatarColor = ""
        email = ""
        name = ""
        AuthService.instance.isLoggedIn = false
        AuthService.instance.userEmail = ""
        AuthService.instance.authToken = ""
        MessageService.instance.clearChannels()
        MessageService.instance.clearMessages()
    }
}
