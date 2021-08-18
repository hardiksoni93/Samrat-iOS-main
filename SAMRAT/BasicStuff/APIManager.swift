//
//  APIManager.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation
import Alamofire



let apiToken = "123"
let language = Language.shared.isArabic ? "ar":"en"
let content_type = "application/json"
let accept = "application/json"
let deviceId = UIDevice.current.identifierForVendor!.uuidString
let deviceType = "1"

struct BaseUrl {
    static let mainUrl = "https://samrat.app/api/"
    static let liveUrl = ""
}

struct ApiUrl {
    
    static let mainUrl = BaseUrl.mainUrl
    
    static let login = mainUrl + "login"
    static let registration = mainUrl + "registration"
    static let singer = mainUrl + "v1/singers"
    static let createBooking = mainUrl + "v1/bookings/create"
    static let getMusicians = mainUrl + "v1/musicians"
    static let mp3Path = "https://samrat.app/public/"
    static let categories = mainUrl + "v1/categories/singers"
    static let change_password = mainUrl + "change-password"
    static let faq = mainUrl + "v1/faqs"
    static let contact_us = mainUrl + "v1/contact-us"
    static let settings = mainUrl + "v1/settings"
    static let BookingServices = mainUrl + "v1/booking-services"
    static let Paymentoption = mainUrl + "v1/bookings/totalBookingAmount"
    static let update = mainUrl + "profile/update"
    static let profile = mainUrl + "profile"
    static let aboutUs = mainUrl + "v1/about-us"
    static let termsAndCondition = mainUrl + "v1/terms-and-conditions"
    static let cancellation_policy = mainUrl + "v1/cancellation-policy"
    static let privacy_policy = mainUrl + "v1/privacy-policy"
    static let get_gallery = mainUrl + "v1/get-gallery"
    static let getBokkings = mainUrl + "v1/bookings/get"
    static let getBokkingsDates = mainUrl + "v1/bookings/getBookingDate?date"
    static let socialLoginRegister = mainUrl + "social-login-register"
    static let forgotPwd = mainUrl + "forgot-password"
    
}


func apiHeaderParam() -> [String : String]?  {
    var headersParam: [String : String] = [String : String]()
    if SamratGlobal.loggedInUser()?.user == nil {
        headersParam = ["Accept":accept,"Content-Type":content_type,"language":Language.shared.isArabic ? "ar":"en","apiToken":apiToken]
    }else {
        let loginToken = SamratGlobal.loggedInUser()?.token ?? ""
        
        headersParam = ["Authorization":loginToken,"Accept":accept,"Content-Type":content_type,"language":Language.shared.isArabic ? "ar":"en","apiToken":apiToken]
        
    }
    return headersParam
}

class APIManager: NSObject {
    
    static let handler = APIManager()
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    enum apiResult {
        case success([String:Any])
        case failure(String)
    }
    
    enum apiResult2 {
        case success(Data?)
        case failure(String)
    }
    
    func serverPostRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            var headers:HTTPHeaders?
            if header == nil {
                headers = ["Content-Type": "application/json"]
            }else {
                headers = header
            }
            
            Alamofire.request(url, method: HTTPMethod.post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in//(header != nil) ? header:
                
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        if isLoader == true {
                            stopLoader()
                        }

                    }
                    break
                    
                case .failure(_):
                    stopLoader()
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
//                    completion(.failure(networkError))
                    break
                }
            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    func serverMultiPartFormRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            let headers = ["Content-Type": "application/json"]
            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in//(header != nil) ? header:
                
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
                    break
                    
                case .failure(_):
                    stopLoader()
                    completion(.failure(networkError))
                }
            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    func serverPostPaymentRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            //            let headers = ["Content-Type": "application/json"]
            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
                    break
                    
                case .failure(_):
                    stopLoader()
                    completion(.failure(networkError))
                }
            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    func serverGetRequest(url:String, isLoader:Bool, header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                //                base.startLoader()
            }
                Alamofire.request(url, method: .get, parameters:nil, encoding: URLEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in
    
                    switch(response.result) {
                    case .success(_):
    
                        if let data = response.result.value {
                            let json = data as? [String:Any] ?? [:]
                            completion(.success(json))
    //                        base.stopLoader()
                        }
                        break
    
                    case .failure(_):
    //                    base.stopLoader()
                        completion(.failure(networkError))
                    }
                }
            
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    
    func serverPostRequest3(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            let headers = ["Content-Type": "application/json"]
            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseString(completionHandler: { (response) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let jsonString = data as? String ?? ""
                        let json = [String: Any]()
                        
                        let string = jsonString
                        let data = string.data(using: .utf8)!
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
                                completion(.success(jsonArray))
                            } else {
                                print("bad json")
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                        stopLoader()
                    }
                    break
                case .failure(_):
                    stopLoader()
                    completion(.failure(networkError))
                }
            })
            //            { (response) in
            //
            //                switch(response.result) {
            //                case .success(_):
            //                    if let data = response.result.value {
            //                        let json = data as? [String:Any] ?? [:]
            //                        completion(.success(json))
            //                        stopLoader()
            //                    }
            //                    break
            //
            //                case .failure(_):
            //                    stopLoader()
            //                    completion(.failure(networkError))
            //                }
            //            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    //MARK:- Search Product
    func searchProduct(_ url: String, isLoader: Bool, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            //            if isLoader == true {
            //                base.startLoader()
            //            }
            //            let headers = ["Content-Type": "application/json"]
            
            Alamofire.SessionManager.default.session.getAllTasks { tasks in tasks.forEach { $0.cancel() }}
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as! [String:Any]
                        completion(.success(json))
                        //                        base.stopLoader()
                    }
                    break
                case .failure(_):
                    //                    base.stopLoader()
                    completion(.failure(networkError))
                }
            }
        } else {
            //            base.stopLoader()
            completion(.failure(networkError))
        }
    }
    
    func PostRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult2) -> ()) {
        JSN.log("url ===>%@", url)
        JSN.log("Parameters ===>%@", params)
        JSN.log("Header ===>%@", apiHeaderParam() as Any)
        
        if Internet.isConnected() == true {
            if isLoader == true {
//                startLoaderWithColor()
            }
            
            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.data {
                        completion(.success(data))
                        if isLoader == true {
//                            stopLoader()
                        }
                    }
                    break
                    
                case .failure(_):
//                    stopLoader()
                    completion(.failure(networkError))
                }
            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    func PostWithCustomHeader(url:String, params:[String:Any], isLoader:Bool,header:[String : String]?,controller:UIViewController? = nil, completion: @escaping (apiResult2) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            
            let loginToken = SamratGlobal.loggedInUser()?.message ?? ""
            
            let tokenType = SamratGlobal.loggedInUser()?.message ?? ""
            
            
            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in
                
                switch(response.result) {
                case .success(_):
                    if let data = response.data {
                        completion(.success(data))
                        stopLoader()
                    }
                    break
                    
                case .failure(_):
                    stopLoader()
                    completion(.failure(networkError))
                }
            }
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
    
    func GetRequest(url:String, isLoader:Bool, header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult2) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                //                base.startLoader()
            }
                Alamofire.request(url, method: .get, parameters:nil, encoding: URLEncoding.default, headers: apiHeaderParam()).responseJSON { (response) in
    
                 switch(response.result) {
                    case .success(_):
                        if let data = response.data {
                            completion(.success(data))
                            stopLoader()
                        }
                        break
                        
                    case .failure(let error):
                        stopLoader()
                        completion(.failure(networkError))
                    }
                }
            
        } else {
            controller?.showAlert(title: alert_title, message: networkError)
//            base.customToast(toastText: networkError, withStatus: toastFailure)
            completion(.failure(networkError))
        }
    }
}



