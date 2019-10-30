//
//  AuthService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/7/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AuthService {
    // Create singleton instance
    static let instance = AuthService()
    
    // Get default instance os UserDefaults
    let defaults = UserDefaults.standard
    
    // Uses UserDefaults to retrieve and update the isLoggedIn parameter.
    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    // Uses UserDefaults to retrieve and update the authToken parameter.
    var authToken: String {
        get {
            return defaults.value(forKey: TOKEN_KEY) as! String
        }
        set {
            defaults.set(newValue, forKey: TOKEN_KEY)
        }
    }
    
    // Uses UserDefaults to retrieve and update the userEmail parameter.
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
    
    // Attempts to register a user into our database.
    // Uses AlamoFire to create the HTTP Request which then passes the boolean result
    // to the closure that was passed as a parameter.
    func registerUser(email: String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let loginParameters = LoginUserParameters(email: lowerCaseEmail, password: password)
        
        AF.request(URL_REGISTER, method: .post, parameters: loginParameters, encoder: JSONParameterEncoder.default, headers: HEADER).responseString { (mResponse) in
            switch mResponse.result {
            case .success:
                print("User Registered")
                completion(true)
            case let .failure(error):
                completion(false)
                print(error)
            }
        }
    }
    
    // Attempts to authenticate a user into our database.
    // Uses AlamoFire to create the HTTP request and if successful updates the locally stored user email and auth token
    // then passes the boolean result to the closure that was passed as a parameter.
    func loginUser(email: String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let loginParameters = LoginUserParameters(email: lowerCaseEmail, password: password)
        
        AF.request(URL_LOGIN, method: .post, parameters: loginParameters, encoder: JSONParameterEncoder.default, headers: HEADER).responseJSON { (mResponse) in
            if mResponse.error == nil {
                do {
                    guard let data = mResponse.data else { return }
                    let json = try JSON(data: data)
                    self.userEmail = json["user"].stringValue
                    self.authToken = json["token"].stringValue
                    self.isLoggedIn = true
                    completion(true)
                } catch {
                    completion(false)
                    print(error.localizedDescription)
                }
            } else {
                print("\(String(describing: mResponse.error?.errorDescription!))")
            }
        }
    }
    
    // Attempts to create a new user into our database.
    // Uses AlamoFire to create the HTTP request and sets all the users info.
    func createUser(name: String, email: String, avatarName: String, avatarColor: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let loginParameters = CreateUserParameters(name: name, email: lowerCaseEmail, avatarName: avatarName, avatarColor: avatarColor)
        
        AF.request(URL_USER_ADD, method: .post, parameters: loginParameters, encoder: JSONParameterEncoder.default, headers: BEARER_HEADER).responseJSON { (response) in
            
            if response.error == nil {
                guard let responseData = response.data else { return }
                self.setUserInfo(data: responseData)
                completion(true)
            } else {
                completion(false)
                debugPrint(response.error.debugDescription)
            }
        }
    }
    
    func findUserEmail(completion: @escaping CompletionHandler) {
        let url = "\(URL_USER_BY_EMAIL)\(userEmail)"
        
        AF.request(url, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
        
            if response.error == nil {
                print("User found by email")
                guard let responseData = response.data else { return }
                self.setUserInfo(data: responseData)
                completion(true)
            } else {
                completion(false)
                print("Error occured when finding user by email")
                debugPrint(response.error.debugDescription)
            }
        }
    }
    
    func setUserInfo(data: Data) {
        do {
            let json = try JSON(data: data)
            let jID = json["_id"].stringValue
            let jAvatarColor = json["avatarColor"].stringValue
            let jAvatarName = json["avatarName"].stringValue
            let jEmail = json["email"].stringValue
            let jName = json["name"].stringValue
            
            UserDataService.instance.setUserData(id: jID, avatarColor: jAvatarColor, avatarName: jAvatarName, email: jEmail, name: jName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    struct LoginUserParameters: Encodable {
        let email: String
        let password: String
    }
    
    struct CreateUserParameters: Encodable {
        let name: String
        let email: String
        let avatarName: String
        let avatarColor: String
    }
}
