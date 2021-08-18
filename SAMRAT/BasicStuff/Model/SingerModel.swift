//
//  SingerModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation

//MARK:- Singer Models

class SingerModel {
    static let shared = SingerModel()
    var singersObj : singersObj?
}


struct singersObj: Codable {
    
    var status: Bool?
    var message: String?
    var token: String?
    var data:[singersData]?
    
}

struct singersData: Codable {
    
    var id:Int?
    var category_id:Int?
    var name:String?
    var description:String?
    var image:String?
    var audio:String?
    var price:String?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var category_name:String?
    var category_description:String?
    var category_image:String?
    var detail_image : String?
    var musicians:[musiciansData]?
    
}

struct musiciansData: Codable {
    
    var id:Int?
    var musician_category_id:Int?
    var name:String?
    var description:String?
    var image:String?
    var audio:String?
    var price:Int?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var category_name:String?
    var category_description:String?
    
    
}













