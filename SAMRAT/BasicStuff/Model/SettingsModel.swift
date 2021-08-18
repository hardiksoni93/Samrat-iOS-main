//
//  SettingsModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 12/05/21.
//

import Foundation


class SettingsModel {
    static let shared = SettingsModel()
    var settingResponseObj:SettingResponse?
}

struct SettingResponse:Codable {
    var status:Bool?
    var message:String?
    var settings:SettingsResponseData?
}


struct SettingsResponseData:Codable {
    var minimum_booking_payment:String?
    var contact_number:String?
    var location:String?
    var email:String?
    var facebook:String?
    var instagram:String?
    var twitter:String?
    var youtube:String?
    var is_cod_enable:String?
    var is_online_payment_enable:String?
    var multiple_singer_booking:String?
    var map_latitude:String?
    var map_longitude:String?
}


