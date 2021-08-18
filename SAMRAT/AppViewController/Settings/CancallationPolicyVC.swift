//
//  CancallationPolicyVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit

class CancallationPolicyVC: UIViewController {
    
    @IBOutlet var txtView: UITextView!
    
    var isPrivacyPolicy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.isPrivacyPolicy == true {
            self.title = Localized("privacyPolicy").uppercased() //"Privacy Policy"
            self.apiGetCSMResponse(url: ApiUrl.privacy_policy)
        }else {
            self.title = Localized("cancellationPolicy").uppercased() //"Cancellation Policy"
            self.apiGetCSMResponse(url: ApiUrl.cancellation_policy)
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

    
    
    //MARK:- API CAlling
    func apiGetCSMResponse(url:String) {
        APIManager.handler.GetRequest(url: url, isLoader: true, header: nil) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    let socialMeadiResponse = try JSONDecoder().decode(CSMResponseObj.self, from: data)
                    
                    if socialMeadiResponse.status == true {
                        self.txtView.attributedText = (socialMeadiResponse.data?.description ?? "").htmlAttributedString(size: 18.0, color: #colorLiteral(red: 0.9277921319, green: 0.927813828, blue: 0.9278021455, alpha: 1))
//socialMeadiResponse.data?.description ?? ""
                    }else {
                        self.showAlert(title: alert_title, message: socialMeadiResponse.message ?? commonError)
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
