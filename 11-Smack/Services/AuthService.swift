//
//  AuthService.swift
//  11-Smack
//
//  Created by Hector Delgado on 10/7/19.
//  Copyright © 2019 hector delgado. All rights reserved.
//
//  Singleton service used for authenticating users.
//  Uses AlamoFire to create the HTTP request and SwiftyJSON to parse the data that is returned.
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
    
    // Used to construct the HTTP parameters to login an existing user
    struct LoginUserParameters: Encodable {
        let email: String
        let password: String
    }
    
    // Used to construct the HTTP parameters to create a new user
    struct CreateUserParameters: Encodable {
        let name: String
        let email: String
        let avatarName: String
        let avatarColor: String
    }
    
    /**
     Attempts to register a user into the database.
     Uses AlamoFire to create the HTTP request which then passes the boolean result to the closure that was passed as a parameter.
     - Parameter email: The email the user entered when creating an account
     - Parameter password: The password the user entered when creating an account
     - Parameter completion: Closure that accepts the boolean result as its parameter (true for no errors, false when an error occured)
     */
    func registerUser(email: String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let loginParameters = LoginUserParameters(email: lowerCaseEmail, password: password)
        
        AF.request(URL_REGISTER, method: .post, parameters: loginParameters, encoder: JSONParameterEncoder.default, headers: HEADER).responseString { (mResponse) in
            if mResponse.error == nil {
                print("User registered")
                completion(true)
            } else {
                completion(false)
                print("Error occured in registering user")
                print(mResponse.error.debugDescription)
            }
        }
    }
    
    /**
     Attempts to authenticate a user into the database.
     Uses AlamoFire to create the HTTP request and passes the boolean result to the closure that was passed as a parameter.
     If successful it stores the users email and auth token locally.
     - Parameter email: The email the user entered to login
     - Parameter password: The password the userd entered to login
     - Parameter completion: Closure that accepts the boolean result as its parameter (true for no errors, false when an error occured)
     */
    func loginUser(email: String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let loginParameters = LoginUserParameters(email: lowerCaseEmail, password: password)
        
        AF.request(URL_LOGIN, method: .post, parameters: loginParameters, encoder: JSONParameterEncoder.default, headers: HEADER).responseString { (mResponse) in
            if mResponse.error == nil {
                print("no errors ")
                print(mResponse.data as Any)
                do {
                    guard let data = mResponse.data else { return }
                    let json = try JSON(data: data)
                    self.userEmail = json["user"].stringValue
                    self.authToken = json["token"].stringValue
                    self.isLoggedIn = true
                    completion(true)
                } catch {
                    completion(false)
                    print("Error parsing JSON Data")
                    print(error.localizedDescription)
                }
            } else {
                print("errors in response")
                print("\(String(describing: mResponse.error?.errorDescription!))")
                completion(false)
            }
        }
    }

    /**
     Attempts to create a new user into the database.
     Uses AlamoFire to create the HTTP request and passes the boolean result to the closure that was passed as a parameter.
     - Parameter name: The username the user entered to create an account.
     - Parameter email: The email the user entered to create an account.
     - Parameter avatarName: The name of the image the user selected as an avatar.
     - Parameter avatarColor: The color the user selected for their avatar.
     - Parameter completion: Closure that accepts the boolean result as its parameter (true for no errors, false when an error occured)
     */
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
    
    /**
     Attempts to gather a users info based on their email.
     - Parameter completion: Closure that accepts the boolean result as its parameter (true for no errors, false when an error occured)
     */
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
    
    /**
     Parses the data passed in to retrieve the users info and store it locally.
     */
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
}
