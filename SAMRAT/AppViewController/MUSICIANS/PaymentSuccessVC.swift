//
//  PaymentSuccessVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import UIKit

class PaymentSuccessVC: UIViewController {

    @IBOutlet var lblPaymentSuceessMsg: UILabel!
    @IBOutlet var lblPaymentSuccessFul: UILabel!
    @IBOutlet var btnBackToHome: UIButton!
    
    var getResponseMsg:createBookingObj? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = Localized("paymentSuccessful").uppercased() //"PAYMENT SUCCESSFUL"
        self.lblPaymentSuceessMsg.text = self.getResponseMsg?.message ?? ""
        self.lblPaymentSuccessFul.text = Localized("paymentSuccessful")
        self.btnBackToHome.setTitle(Localized("backToHome"), for: .normal)
        
        var imageLeft = UIImage(named: "")
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
//        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBacktohomeAction(_ sender: Any) {
        self.navigateToWelcomeScreen()
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
