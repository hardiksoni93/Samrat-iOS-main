import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import SwiftKeychainWrapper

class LoginViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet var btnSignInwithGoogle: UIButton!
    @IBOutlet var btnAgreeTermsCondition: UIButton!
    @IBOutlet var lblIsDontHaveAccount: UILabel!
    
    @IBOutlet var btnSigninWithApple: UIButton!
    @IBOutlet var btnSigninFacebook: UIButton!
    @IBOutlet var btnFotgot: UIButton!
    @IBOutlet var txtMobileEmail: UITextField!{
        didSet{
            txtMobileEmail.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            txtMobileEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var txtPassword: UITextField!{
        didSet{
            txtPassword.roundCorners(corners: [.bottomRight], radius: 10.0)
            txtPassword.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
            btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10.0)
            btnSubmit.clipsToBounds = true
        }
    }
    
    var isNeedtobackToScreen:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- Update txt
        self.title = Localized("login").uppercased()
        self.btnFotgot.setTitle(Localized("forgotPassword"), for: .normal)
        self.txtMobileEmail.placeholder = Localized("email") //Localized("emailMobile")
        self.txtPassword.placeholder = Localized("password")
        self.btnAgreeTermsCondition.setTitle(Localized("agreeTermsCondition"), for: .normal)
        self.btnAgreeTermsCondition.setTitle(Localized("agreeTermsCondition"), for: .selected)
        self.btnSignInwithGoogle.setTitle(Localized("signInWithGoogle"), for: .normal)
        self.btnSigninFacebook.setTitle(Localized("signInWithFacebook"), for: .normal)
        self.btnSigninWithApple.setTitle(Localized("signInWithApple"), for: .normal)
        self.lblIsDontHaveAccount.text = Localized("ifDontHaveAccount")
        self.btnRegister.setTitle(Localized("registration"), for: .normal)
        
        if Language.shared.isArabic == true {
            self.txtMobileEmail.textAlignment = .right
            self.txtPassword.textAlignment = .right
        }
        
        
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        //        self.txtMobileEmail.text = "testing@gmail.com"
        //        self.txtPassword.text = "12345678"
        
        // Do any additional setup after loading the view.
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTaptermsAndConditionAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "2"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func googleSignInAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func loginClick(_ sender: Any) {
        if self.btnAgreeTermsCondition.isSelected == false {
            self.showAlert(title: alert_title, message: Localized("youmustAgreeTermsCondition"))
            return
        }
        DispatchQueue.main.async {
            if self.txtMobileEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
                self.showAlert(title: alert_title, message: Localized("pEnterEmailAddress"))
                return
            }
            if self.isValidEmail(testStr: self.txtMobileEmail.text ?? "") == true {
                if (self.txtPassword.text?.trimmingCharacters(in: .whitespaces).count ?? 0) >= 6 {
                    self.signInAPI()
                }else {
                    self.showAlert(title: alert_title, message: Localized("pwdLengthAlert"))
                }
            }else {
                self.showAlert(title: alert_title, message: Localized("pEnterValidEmailAddress"))
            }   
        }
    }
    
    @IBAction func forgotPasswordClick(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registerClick(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapApplePayLogin(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    @IBAction func onTapFacebookLoginAction(_ sender: UIButton) {
        self.fbLoginProcess()
    }
    
    func fbLoginProcess() {
        let fbLoginManager : LoginManager = LoginManager()
        
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    
                }
            }
        }
    }
    
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender, birthday"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){// , phone, picture.type(large)
                    //everything works print the user data
                    if let dicData = result as? NSDictionary {
                        let name = dicData.value(forKey: "name") as? String
                            
                            //((dicData.value(forKey: "first_name")) as? String) ?? "" + " " + ((dicData.value(forKey: "last_name")) as? String ?? "")
                        
                        let email = dicData.value(forKey: "email") as? String
                        let id = dicData.value(forKey: "id") as? String
                        if email == nil {
                            self.showAlert(title: alert_title, message: Localized("pAllowToAccessEmail"))
                            return
                        }
                        if let getFbId = id {
                            self.apiSocialLogin(email ?? "", getFbId, name ?? "")
                        }
                        //                        self.checkEmailExist(first_name: dicData.value(forKey: "first_name") as? String, last_name: dicData.value(forKey: "last_name") as? String, email: dicData.value(forKey: "email") as? String)
                    }
                }
            })
        }
    }
    
    
    
    //MARK:- Login API Calling
    func signInAPI() {
        let parameter = [
            "email" : self.txtMobileEmail.text ?? "",
            "password" : self.txtPassword.text ?? ""
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.login, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    UserModel.shared.objUser = nil
                    UserModel.shared.objUser = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if UserModel.shared.objUser?.status == true {
                        loginOption.shared.normalLogin(true)
                        if let userData = UserModel.shared.objUser {
                            //                            UserDefaults.standard.encode(for: UserKey.loginUserData, using: userData)
                            UserDefaults.standard.encode(for: userData, using: UserKey<LoginResponse>.loginUserData)
                            if UserModel.shared.objUser?.status == true {
                                if self.isNeedtobackToScreen == true {
                                    self.navigationController?.popViewController(animated: true)
                                }else {
                                    self.navigateToWelcomeScreen()
                                }
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
    
    //MARK:- API Social Login
    func apiSocialLogin(_ userEmail:String,_ socialId:String,_ userName:String) {
        let parameter = [
            "email" : userEmail,
            "social_id" : socialId,
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
                        if socialLoginResponse.is_new_user == true {
                            let vc = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
                            vc.isSocialSignUp = true
                            vc.socialUserName = userName
                            vc.socialEmailAddress = userEmail
                            vc.socialId = socialId
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else {
                            //                            loginOption.shared.normalLogin(true)
                            
                            //                            UserDefaults.standard.encode(for: UserKey.loginUserData, using: userData)
                            UserDefaults.standard.encode(for: socialLoginResponse, using: UserKey<LoginResponse>.loginUserData)
                            if socialLoginResponse.status == true {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }else {
                        self.showAlert(title: alert_title, message: socialLoginResponse.message ?? commonError)
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

//MARK:- Google SignUp method
extension LoginViewController {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        if let fName = fullName {
            //            self.name_TF.text = fName
        }
        
        if let getemail = email {
            //            self.txtMobileEmail.text = getemail
        }
        
        //        loginOption.shared.googleLogin(true)
        if email == "" || email == nil {
            self.showAlert(title: alert_title, message: Localized("pAllowToAccessEmail"))
            return
        }
        self.apiSocialLogin(email ?? "", userId ?? "", fullName ?? "")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error.localizedDescription)
        JSN.log("error ===>%@", error.localizedDescription)
        //        self.showAlert(title: alert_title, message: error.localizedDescription)
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print(error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let appleId = appleIDCredential.user
            let appleUserFirstName = appleIDCredential.fullName?.givenName ?? ""
            let appleUserLastName = appleIDCredential.fullName?.familyName ?? ""
            let appleUserEmail = appleIDCredential.email
            
            let retrievedString: String? = KeychainWrapper.standard.string(forKey: appleId)
            if retrievedString != nil {
//                self.apiSocialLogin(retrievedString ?? "", appleId, (appleUserFirstName ?? "") + " " + (appleUserLastName ?? ""))
                self.apiSocialLogin(retrievedString ?? "", appleId, "")
                //                self.checkEmailExist(first_name: appleUserFirstName, last_name: appleUserLastName, email: retrievedString)
            } else {
                let saveSuccessful: Bool = KeychainWrapper.standard.set(appleUserEmail ?? "", forKey: appleId)
                if saveSuccessful {
                    self.apiSocialLogin(retrievedString ?? "", appleId, appleUserFirstName + " " + appleUserLastName)
                    //                    self.checkEmailExist(first_name: appleUserFirstName, last_name: appleUserLastName, email: appleUserEmail)
                }
            }
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            self.showAlert(title: username, message: password)
            
            //Navigate to other view controller
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    //For present window
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
        
    }
}

