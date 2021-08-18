//
//  LoginResponse.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation

//MARK:- LogineResponse

class UserModel {
    static let shared = UserModel()
    var objUser : LoginResponse?
}


struct CommanResponse:Codable {
    var status:Bool?
    var message:String?
}


struct LoginResponse: Codable {
    
    var status:Bool?
    var message:String?
    var is_new_user:Bool?
    var token:String?
    var user:LoginUser?
    
}

struct LoginUser: Codable {
    var id:Int?
    var name:String?
    var username:String?
    var email:String?
    var mobile_no:String?
    var address:String?
    var comment:String?
    var term_condition:Int?
//    var device:String?
    var device_id:String?
    var status:Int?
    var is_social:Int?
    var social_id:String?
    var created_at:String?
    var updated_at:String?
}

