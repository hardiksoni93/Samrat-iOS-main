import UIKit
import UITextView_Placeholder
import MessageUI

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var txtMobile: UITextField!{
        didSet{
            txtMobile.layer.borderWidth = 1
            txtMobile.layer.borderColor = UIColor.white.cgColor
            txtMobile.layer.cornerRadius = 10
            txtMobile.attributedPlaceholder = NSAttributedString(string:"Mobile", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//            txtMobile.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            txtMobile.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.layer.borderWidth = 1
            txtEmail.layer.borderColor = UIColor.white.cgColor
            txtEmail.layer.cornerRadius = 10
            txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//            txtEmail.roundCorners(corners: [.bottomRight], radius: 0.0)
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtMessage: UITextView!{
        didSet{
            txtMessage.layer.borderWidth = 1
            txtMessage.layer.borderColor = UIColor.white.cgColor
            txtMessage.layer.cornerRadius = 10
//            txtMessage.roundCorners(corners: [.bottomRight], radius: 10.0)
            txtMessage.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
//            btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
            btnSubmit.layer.cornerRadius = 25
            btnSubmit.clipsToBounds = true
        }
    }
    
    @IBOutlet var imgContact: UIImageView!{
        didSet{
            imgContact.layer.cornerRadius = 10.0
            imgContact.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnYoutube: UIButton!
    @IBOutlet var btnInsta: UIButton!
    @IBOutlet var btnFb: UIButton!
    @IBOutlet var btnTwitter: UIButton!
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var btnMail: UIButton!
    var settingsResponse:SettingResponse? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localized("contactUs") //"Contact Us"
        self.txtEmail.placeholder = Localized("email")
        self.txtMobile.placeholder = Localized("mobile")
        self.txtMessage.placeholder = Localized("message")
//        if Language.shared.isArabic {
//            self.txtEmail.textAlignment = .right
//            self.txtMobile.textAlignment = .right
//            self.txtMessage.textAlignment = .right
//        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.apiGetSettingDetails()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: app_name, message: Localized("pEnterEmailAddress"))
            return
        }
        
        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == false {
            self.showAlert(title: app_name, message: Localized("pEnterValidEmailAddress"))
            return
        }
        
        if self.txtMobile.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: app_name, message: Localized("pEnterMobilenumber"))
            return
        }
        
        if (self.txtMobile.text?.count ?? 0) < 8 {
            self.showAlert(title: app_name, message: Localized("pEnterValidMobileNumber"))
            return
        }
        
        self.apiContactUs()
        
    }
    
    @IBAction func onTapYoutubeLink(_ sender: UIButton) {
        if let getYoutubeUrl = self.settingsResponse?.settings?.youtube {
            self.openUrl(getYoutubeUrl)
        }
    }
    
    @IBAction func onTapInstaAction(_ sender: UIButton) {
        if let getInstaUrl = self.settingsResponse?.settings?.instagram {
            self.openUrl(getInstaUrl)
        }
    }
    
    @IBAction func onTapFacebookAction(_ sender: UIButton) {
        if let getFacebookUrl = self.settingsResponse?.settings?.facebook {
            self.openUrl(getFacebookUrl)
        }
    }
    
    @IBAction func onTapTwitterAction(_ sender: UIButton) {
        if let getTwitterUrl = self.settingsResponse?.settings?.twitter {
            self.openUrl(getTwitterUrl)
        }
    }
    
    @IBAction func onTapCallAction(_ sender: UIButton) {
        if let url = URL(string: "tel://\(self.settingsResponse?.settings?.contact_number ?? "")"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onTapEmailAction(_ sender: UIButton) {
        self.sendEmail()
    }
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.settingsResponse?.settings?.email ?? ""])
//            mail.setMessageBody("", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    func openUrl(_ urlString:String) {
        let url: URL?
        if urlString.hasPrefix("https://") {
            url = URL(string: urlString)
        } else {
            url = URL(string: "https://" + urlString)
        }
        if let getUrl = url {
            UIApplication.shared.open(getUrl)
        }
    }
    
    //MARK:- Contact US API Calling
    func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.settingsResponse = try? JSONDecoder().decode(SettingResponse.self, from: getDara)
                        if self.settingsResponse?.status == true {
                            let settings = self.settingsResponse?.settings
                            if (settings?.contact_number ?? "") == "" {
                                self.btnCall.isHidden = true
                            }else {
                                self.btnCall.isHidden = false
                            }
                            
                            if (settings?.youtube ?? "") == "" {
                                self.btnYoutube.isHidden = true
                            }else {
                                self.btnYoutube.isHidden = false
                            }
                            
                            if (settings?.instagram ?? "") == "" {
                                self.btnInsta.isHidden = true
                            }else {
                                self.btnInsta.isHidden = false
                            }
                            
                            if (settings?.facebook ?? "") == "" {
                                self.btnFb.isHidden = true
                            }else {
                                self.btnFb.isHidden = false
                            }
                            
                            if (settings?.twitter ?? "") == "" {
                                self.btnTwitter.isHidden = true
                            }else {
                                self.btnTwitter.isHidden = false
                            }
                            
                            if (settings?.email ?? "") == "" {
                                self.btnMail.isHidden = true
                            }else {
                                self.btnMail.isHidden = false
                            }
                            
                            
                        }else {
                            self.showAlert(title: app_name, message: self.settingsResponse?.message ?? commonError) {
                                
                            }
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                }catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- Contact US API Calling
    func apiContactUs() {
        let parameter = [
            "name" : SamratGlobal.loggedInUser()?.user?.username ?? "",
            "phone" : self.txtMobile.text ?? "",
            "email":self.txtEmail.text ?? "",
            "message":self.txtMessage.text ?? ""
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.contact_us, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        let contactUsResponse = try? JSONDecoder().decode(CommanResponse.self, from: getDara)
                        if contactUsResponse?.status == true {
                            self.showAlert(title: app_name, message: contactUsResponse?.message ?? commonError) {
                                self.view.endEditing(true)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            self.showAlert(title: app_name, message: contactUsResponse?.message ?? commonError) {
                                
                            }
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                }catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
}
