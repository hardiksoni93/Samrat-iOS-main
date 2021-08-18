//
//  CreateBookingModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import Foundation

class CreateBookingModel {
    static let shared = CreateBookingModel()
    var createBookObj : createBookingObj?
}

struct createBookingObj: Codable {
    var status:Bool?
    var message:String?
    
}
