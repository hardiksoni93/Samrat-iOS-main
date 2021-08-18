//
//  EditProfileVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 04/05/21.
//

import UIKit

class EditProfileVC: UIViewController {

    @IBOutlet var txtfName: UITextField!
    @IBOutlet var txtfPhoneNumber: UITextField!
    @IBOutlet var txtfEmailAddress: UITextField!
    @IBOutlet var txtfAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "MY PROFILE"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.txtfName.text = SamratGlobal.loggedInUser()?.user?.name ?? ""
        self.txtfPhoneNumber.text = SamratGlobal.loggedInUser()?.user?.mobile_no ?? ""
        self.txtfEmailAddress.text = SamratGlobal.loggedInUser()?.user?.email ?? ""
        self.txtfAddress.text = SamratGlobal.loggedInUser()?.user?.address ?? ""
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    

    @IBAction func btnUpdateProfileAction(_ sender: UIButton) {
        if self.txtfName.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: app_name, message: "Please enter name!")
            return
        }
        
        if self.txtfEmailAddress.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: app_name, message: "Please enter email address")
            return
        }
        
        if (self.txtfPhoneNumber.text?.trimmingCharacters(in: .whitespaces).count ?? 0) >= 10 {
            self.showAlert(title: app_name, message: "Please enter email address")
            return
        }
        
//        if self.txtfAddress.text?.trimmingCharacters(in: .whitespaces) == "" {
//            self.showAlert(title: app_name, message: "Please enter address")
//            return
//        }
        
        
        self.apiUpdateProfile()
        
    }
    
    
    //MARK:- Contact US API Calling
    func apiUpdateProfile() {
        let parameter = [
            "username" : self.txtfName.text ?? "",
            "email":self.txtfEmailAddress.text ?? "",
            "mobile_no":self.txtfPhoneNumber.text ?? "",
            "address":self.txtfAddress.text ?? "",
            "commnet":""
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.update, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        let contactUsResponse = try JSONDecoder().decode(CommanResponse.self, from: getDara)
                        if contactUsResponse.status == true {
                            self.updateUserDetails()
                            self.showAlert(title: app_name, message: contactUsResponse.message ?? commonError) {
                                self.view.endEditing(true)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            self.showAlert(title: app_name, message: contactUsResponse.message ?? commonError) {
                                
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
