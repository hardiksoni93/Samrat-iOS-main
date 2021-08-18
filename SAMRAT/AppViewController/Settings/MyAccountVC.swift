//
//  MyAccountVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class MyAccountVC: UIViewController {

    @IBOutlet var img1: UIImageView!
    @IBOutlet var img2: UIImageView!
    @IBOutlet var img3: UIImageView!
    @IBOutlet var img4: UIImageView!
    
    @IBOutlet var lblEditprofile: UILabel!
    @IBOutlet var lblManageBooking: UILabel!
    @IBOutlet var lblChangerPwd: UILabel!
    @IBOutlet var lblLogout: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = Localized("myAccount").uppercased() //"MY ACCOUNT"
        self.lblEditprofile.text = Localized("editProfile")
        self.lblManageBooking.text = Localized("manageBookings")
        self.lblChangerPwd.text = Localized("changePassword")
        self.lblLogout.text = Localized("logout")
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        if Language.shared.isArabic {
            self.img1.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img2.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img3.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img4.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        }
    }
    
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapEditProfileAction(_ sender: UIControl) {
        let editProfileVC = EditProfileVC()
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func onTapLogouteAction(_ sender: UIControl) {
        let alertController = UIAlertController.init(title: alert_title, message: Localized("wouldYouLikeLogOut"), preferredStyle: .alert)
        let yAction = UIAlertAction.init(title: Localized("yes"), style: .default) { (yAct) in
            UserDefaults.standard.removeObject(forKey: UserKey<LoginResponse>.loginUserData.rawValue)
            self.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
        }
        let nAction = UIAlertAction.init(title: Localized("no"), style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(yAction)
        alertController.addAction(nAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onTapChangePwdAction(_ sender: UIControl) {
        let changePwdVc =  ChangePasswordVC()
        self.navigationController?.pushViewController(changePwdVc, animated: true)
    }
    
    @IBAction func onTapManageBookingAction(_ sender: UIControl) {
        let myBookingVC = MyBookingVC()
        self.navigationController?.pushViewController(myBookingVC, animated: true)
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
