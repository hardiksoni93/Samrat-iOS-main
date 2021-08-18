//
//  SamratGlobal.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation


var oneSignalId = "f3649d6c-c9f6-45fc-a90c-c8ab8cf7dd96"

struct SamratGlobal {
    static func loggedInUser() -> LoginResponse?{
        
        guard let userData = UserDefaults.standard.decode(for: LoginResponse.self, using: UserKey<LoginResponse>.loginUserData) else {
            return nil
        }
        
        return userData
    }
    
}


class loginOption {
    static let shared = loginOption()
    var isAppleSignUp = false
    var isGoogleSignUp = false
    var isfacebookSignUp = false
    var isGuestUser = false
    var isNormal = false
    
    func normalLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isNormal = isLogin
    }
    
    func appleLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isAppleSignUp = isLogin
    }
    
    func googleLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isGoogleSignUp = isLogin
    }
    
    func facebookLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isfacebookSignUp = isLogin
    }
    
    func guestUserLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isGuestUser = isLogin
    }
    
    func allLoginDisable() {
        loginOption.shared.isNormal = false
        loginOption.shared.isAppleSignUp = false
        loginOption.shared.isGoogleSignUp = false
        loginOption.shared.isfacebookSignUp = false
        loginOption.shared.isGuestUser = false
    }
}


extension UserDefaults {
    func decode<T: Codable>(for type: T.Type, using key: UserKey<T>?) -> T? {
        guard let keys = key else {
            return nil
        }
        
        let defaults = UserDefaults.standard
        guard let data = defaults.object(forKey: keys.rawValue) as? Data else {return nil}
        let decodedObject = try? PropertyListDecoder().decode(type, from: data)
        return decodedObject
    }
    
    func encode<T: Codable>(for type: T, using key: UserKey<T>?) {
        guard let keys = key else {
            return
        }
        
        let defaults = UserDefaults.standard
        let encodedData = try? PropertyListEncoder().encode(type)
        defaults.set(encodedData, forKey: keys.rawValue)
        defaults.synchronize()
    }
    
}

