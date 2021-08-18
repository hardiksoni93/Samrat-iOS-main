//
//  BasicStuff.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import Foundation
import UIKit
import SVProgressHUD
import SystemConfiguration
import KRActivityIndicatorView
import KRProgressHUD


struct JSN {
    static var isNetworkConnected:Bool = false
    static func log(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("LOG :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
    static func error(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("ERROR :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
}


class Language : NSObject {
    static let shared:Language = Language()
    let APPLE_LANGUAGE_KEY = "AppleLanguages"
    
    var currentAppLang:String {
        return self.isArabic ? "ar" : "en"
    }
    var isArabic:Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isLangugeSet")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isLangugeSet")
        }
    }
    
    
    override init() {
        super.init()
    }
}

class CalanderSelectionModel: NSObject {
    static var shared = CalanderSelectionModel()
    var isArabic : Bool?
}


//extension String {
//    var htmlToAttributedString: NSAttributedString? {
//        guard let data = data(using: .utf8) else { return nil }
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return nil
//        }
//    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
//
//
//
//}

extension String {
    func htmlAttributedString(size: CGFloat, color: UIColor) -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                color: \(color.hexString!);
                font-family: -apple-system;
                font-size: \(size)px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
}

extension UIColor {
    var hexString:String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "#%02x%02x%02x", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
}





extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
    
}

struct Colors {
    static let snomo = UIColor.rgb(red: 204, green: 138, blue: 101)
    static let snomoTransparant = UIColor.rgb(red: 204, green: 138, blue: 101)
}

extension UIStoryboard {
    enum Name: String {
        case main = "Main"
    }
}



extension UIViewController {
    static func object(_ storyboardName: UIStoryboard.Name = UIStoryboard.Name.main) -> Self {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: Self.self)) as! Self
    }
    static func object(_ string:String,_ storyboardName: UIStoryboard.Name = UIStoryboard.Name.main) -> Self {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: string) as! Self
    }
    
    static func nib() -> Self {
        return UIViewController(nibName: String(describing: Self.self), bundle: Bundle.main) as! Self
    }
    
    func showAlert(title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title : String, message : String,_ completionhandler:(@escaping(()->()))) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (okAct) in
            completionhandler()
        }//UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

public func hexStringToUIColor(hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//MARK:- Validation message
extension UIViewController {
    //MARK: EMAIL VALIDATION
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension UIViewController {
    func navigateToHome() {
        
        let frontViewController = LoginViewController.object() //TabBarController.object()
        let frontNavigationController = UINavigationController(rootViewController: frontViewController)
        frontNavigationController.setNavigationBarHidden(true, animated: false)
        self.view.window?.rootViewController = frontNavigationController
    }
    var notchHeight:CGFloat {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets.top
//        let bottomPadding = window.safeAreaInsets.bottom
    }
    
    
    func navigateToWelcomeScreen() {
        
        let frontViewController = TabBarViewController.object() //TabBarController.object()
        let frontNavigationController = UINavigationController(rootViewController: frontViewController)
        frontNavigationController.setNavigationBarHidden(false, animated: false)
        self.view.window?.rootViewController = frontNavigationController
    }
}

//MARK:- Change Date Formate
extension UIViewController {
    func convertDateFormater(_ date: String, oriDateFormate:String = "yyyy-MM-dd HH:mm:ss z",requiredDateFormate:String = "") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oriDateFormate
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = requiredDateFormate
        return  dateFormatter.string(from: date!)
        
    }
}

//MARK:- Add Shadow
extension UIView {
    func shadow(shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func buttonShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
    func tabShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 4
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func addLightShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func removeShadow() {
        
    }
    
    func addShadow2() {
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
    }
}


//MARK: START LOADER
func startLoader() {
    
    KRProgressHUD.show()
//    SVProgressHUD.show()
//    SVProgressHUD.setForegroundColor(.clear)//(AppColor.theme)
//    SVProgressHUD.setRingThickness(3)
//    SVProgressHUD.setBackgroundColor(.clear)//(UIColor.white)
//    SVProgressHUD.setDefaultMaskType(.clear)//(.black)
}
func startLoaderWithColor() {
    //    UIApplication.shared.beginIgnoringInteractionEvents()
//    SVProgressHUD.show()
//    SVProgressHUD.setForegroundColor(Colors.snomo)
//    SVProgressHUD.setRingThickness(3)
//    SVProgressHUD.setBackgroundColor(UIColor.white)
//    SVProgressHUD.setDefaultMaskType(.black)
    
//    KRProgressHUD.set(activityIndicatorViewColors: [Colors.snomo])
//    KRProgressHUD.show()

//    let image = UIImage(named: "loading-icon_2.gif")!
//
//    KRProgressHUD.showImage(image, size: CGSize(width: 175, height: 175),message: nil)
}

//MARK: STOP LOADER
func stopLoader() {
    //    UIApplication.shared.endIgnoringInteractionEvents()
//    SVProgressHUD.dismiss()
    KRProgressHUD.dismiss()
}


public class Internet {
    
    class func isConnected() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}


//MARK:- Tableview Extensions
final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}




