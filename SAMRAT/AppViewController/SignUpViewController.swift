import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet var txtName: UITextField!{
        didSet{
            txtName.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            txtName.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtMobile: UITextField!{
        didSet{
            txtMobile.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtMobile.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtPassword: UITextField!{
        didSet{
            txtPassword.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtPassword.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtConfirmPassword: UITextField!{
        didSet{
            txtConfirmPassword.roundCorners(corners: [.bottomRight], radius: 10.0)
            txtConfirmPassword.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
            btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10.0)
            btnSubmit.clipsToBounds = true
        }
    }
    
    
    @IBOutlet var btnAggreTermsCondition: UIButton!
    
    var isSocialSignUp = false
    var socialUserName = ""
    var socialEmailAddress = ""
    var socialId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Localized("signUp").uppercased() //"SIGN UP"
        self.btnAggreTermsCondition.setTitle(Localized("agreeTermsCondition"), for: .normal)
        self.btnAggreTermsCondition.setTitle(Localized("agreeTermsCondition"), for: .selected)
        
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        // Do any additional setup after loading the view.
        if self.isSocialSignUp == true {
            self.txtEmail.text = self.socialEmailAddress
            self.txtEmail.isUserInteractionEnabled = false
            self.txtName.text = self.socialUserName
            self.txtPassword.isHidden = self.isSocialSignUp
            self.txtConfirmPassword.isHidden = self.isSocialSignUp
        }
        
        self.updateArabicTxt()
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func updateArabicTxt() {
        self.txtName.placeholder = Localized("name")
        self.txtMobile.placeholder = Localized("mobile")
        self.txtEmail.placeholder = Localized("email")
        self.txtPassword.placeholder = Localized("password")
        self.txtConfirmPassword.placeholder = Localized("confirmPassword")
        self.btnSubmit.setTitle(Localized("registration").uppercased(), for: .normal)
        
        if Language.shared.isArabic == true {
            self.txtName.textAlignment = .right
            self.txtMobile.textAlignment = .right
            self.txtEmail.textAlignment = .right
            self.txtPassword.textAlignment = .right
            self.txtConfirmPassword.textAlignment = .right
        }
        
        
    }
    
    @IBAction func onTapTermsAndConditionAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "2"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        
        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: alert_title, message: Localized("pEnterEmailAddress"))
            return
        }
        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == false {
            self.showAlert(title: alert_title, message: Localized("pEnterValidEmailAddress"))
            return
        }
        
        if self.txtName.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: alert_title, message: Localized("pEntername"))
            return
        }
        
        if (self.txtMobile.text?.count ?? 0) < 8 {
            self.showAlert(title: alert_title, message: Localized("pEnterValidMobileNumber"))
            return
        }
        
        
        if self.isSocialSignUp == false {
            if self.txtPassword.text?.trimmingCharacters(in: .whitespaces) == "" {
                self.showAlert(title: alert_title, message: Localized("pEnterPassword"))
                return
            }
            
            if (self.txtPassword.text?.count ?? 0) < 6 {
                self.showAlert(title: alert_title, message: Localized("pwdLengthAlert"))
                return
            }
            
            
            if (self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces) == "") {
                self.showAlert(title: alert_title, message: Localized("pEnterCp"))
                return
            }
            
            if self.txtPassword.text?.trimmingCharacters(in: .whitespaces) != self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces) {
                self.showAlert(title: alert_title, message: Localized("passwrodNotMatch"))
                return
            }
            
            
            if self.btnAggreTermsCondition.isSelected == false {
                self.showAlert(title: alert_title, message: Localized("youmustAgreeTermsCondition"))
                return
            }


        }
        
        if self.isSocialSignUp == true {
            self.apiSocialLogin(self.txtEmail.text ?? "", self.socialId, self.txtName.text ?? "")
        }else {
            self.signUpAPI()
        }
    }
    
    
    //MARK:- API Signup API
    func signUpAPI() {
        let parameter = [
            "name" : self.txtName.text ?? "",
            "email" : self.txtEmail.text ?? "",
            "mobile_no":self.txtMobile.text ?? "",
            "password":self.txtPassword.text ?? "",
            "password_confirmation":self.txtConfirmPassword.text ?? "",
            "term_condition":"1",
            "device":deviceType,
            "device_id":deviceId
            
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.registration, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    UserModel.shared.objUser = try? JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if UserModel.shared.objUser?.status == true {
                        loginOption.shared.normalLogin(true)
                        if let userData = UserModel.shared.objUser {
                            //                            UserDefaults.standard.encode(for: UserKey.loginUserData, using: userData)
                            UserDefaults.standard.encode(for: userData, using: UserKey<LoginResponse>.loginUserData)
                            if UserModel.shared.objUser?.status == true {
                                self.navigateToWelcomeScreen()
                            }
                        }
                    }else {
                        self.showAlert(title: alert_title, message: UserModel.shared.objUser?.message ?? commonError)
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                    }
                    
                    
                }
                catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- SOCIAL SINGUP API CAlling
    func apiSocialLogin(_ userEmail:String,_ socialId:String,_ userName:String) {
        let parameter = [
            "name":self.txtName.text ?? "",
            "email" : userEmail,
            "mobile_no" : self.txtMobile.text ?? "",
            "term_condition" : true,
            "social_id" : socialId,
            "address" : "",
            "comment" : "",
            "device_id" : deviceId,
            "device" : deviceType
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.socialLoginRegister, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                     let socialLoginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if socialLoginResponse.status == true {
                        loginOption.shared.googleLogin(true)
                        
                            //                            UserDefaults.standard.encode(for: UserKey.loginUserData, using: userData)
                            UserDefaults.standard.encode(for: socialLoginResponse, using: UserKey<LoginResponse>.loginUserData)
                            if socialLoginResponse.status == true {
                                self.navigateToWelcomeScreen()
                            }
                        
                    }else {
                        self.showAlert(title: alert_title, message: UserModel.shared.objUser?.message ?? commonError)
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                    }
                    
                }
                catch (let error) {
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
