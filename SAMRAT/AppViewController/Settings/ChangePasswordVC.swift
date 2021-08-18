//
//  ChangePasswordVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet var txtfOldPwd: UITextField!
    @IBOutlet var txtfNewPwd: UITextField!
    @IBOutlet var txtfConfirmPwd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = Localized("changePassword")//"CHANGE PASSWORD"
        self.txtfOldPwd.placeholder = Localized("oldPwd")
        self.txtfNewPwd.placeholder = Localized("newPwd")
        self.txtfConfirmPwd.placeholder = Localized("confirmPassword")
        
        if Language.shared.isArabic == true {
            self.txtfOldPwd.textAlignment = .right
            self.txtfNewPwd.textAlignment = .right
            self.txtfConfirmPwd.textAlignment = .right
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func onTapSubmitAction(_ sender: UIButton) {
        //        self.navigateToHome()
        //        self.navigateToWelcomeScreen()
        self.apiChangePwd()
    }
    
    
    
    
    //MARK:- API Change Pwd
    func apiChangePwd() {
        
        if self.txtfOldPwd.text == "" {
            self.showAlert(title: alert_title, message: "Old Password empty!!")
            return
        }
        
        
        if self.txtfNewPwd.text == "" {
            self.showAlert(title: alert_title, message: "Please Add New Password")
            return
        }
        
        if self.txtfConfirmPwd.text == "" {
            self.showAlert(title: alert_title, message: "Please Add Confirm Password")
            return
        }
        
        
        if self.txtfNewPwd.text != self.txtfConfirmPwd.text {
            self.showAlert(title: alert_title, message: "Password and Confirm Password does not match")
        }
        
        
        let parameter = [
            "old_password" : self.txtfOldPwd.text ?? "",
            "password" : self.txtfNewPwd.text ?? "",
            "password_confirmation": self.txtfConfirmPwd.text ?? ""
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.change_password, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getResponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                    
                    if getResponse?.status == true {
                        self.navigateToWelcomeScreen()
                    }else {
                        self.showAlert(title: alert_title, message: getResponse?.message ?? commonError)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
