import UIKit
import MASegmentedControl
import WMSegmentControl

class SettingsViewController: UIViewController {
    
    @IBOutlet var lblLang: UILabel!
    @IBOutlet var lblNotification: UILabel!
    @IBOutlet var lblMyAccount: UILabel!
    //    @IBOutlet var lblFaq: UILabel!
    @IBOutlet var lblContactUs: UILabel!
    @IBOutlet var lblTermsAndCondition: UILabel!
    @IBOutlet var lblAboutUs: UILabel!
    //    @IBOutlet var lblCancellationPolicy: UILabel!
    //    @IBOutlet var lblPrivacyPolicy: UILabel!
    @IBOutlet var lblLogout: UILabel!
    //    @IBOutlet var lblNotiOn: UILabel!
    //    @IBOutlet var lblNotiOff: UILabel!
    @IBOutlet var myAcountContainView: UIControl!
    //    @IBOutlet var btnLang: UIButton!
    //    @IBOutlet var btnNoti: UIButton!
    @IBOutlet var langSegment: UISegmentedControl!
    
    @IBOutlet var notificationSegment: UISegmentedControl!
    
    @IBOutlet var segmentControlNoti : HBSegmentedControl!
    @IBOutlet var segmentControlLang : HBSegmentedControl!
    var isNotification = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        self.btnNoti.isSelected = (isNotification == true) ?false:true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = Localized("settings").uppercased() //"SETTINGS"
        
                self.langSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
                self.notificationSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        //        self.btnLang.isSelected = (Language.shared.isArabic == true) ? true:false
        self.langSegment.selectedSegmentIndex = (Language.shared.isArabic == true) ? 1:2
        self.notificationSegment.setTitle(Localized("on"), forSegmentAt: 0)
        self.notificationSegment.setTitle(Localized("off"), forSegmentAt: 1)
        
        
        //Custom Segment Class for Notification
        segmentControlNoti.items = [Localized("on"), Localized("off")]
        segmentControlNoti.font = UIFont.systemFont(ofSize: 12)
        segmentControlNoti.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControlNoti.selectedIndex = 0
        segmentControlNoti.padding = 0
        
        segmentControlNoti.addTarget(self, action: #selector(self.segmentValueChangedForNoti(_:)), for: .valueChanged)
        
        
        //Custom Segment Class for Language
        segmentControlLang.items = ["English", "عربي"]
        segmentControlLang.font = UIFont.systemFont(ofSize: 12)
        segmentControlLang.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControlLang.selectedIndex = (Language.shared.isArabic == true) ? 1:0
//        segmentControlLang.selectedIndex = 0
        segmentControlLang.padding = 0
        
        segmentControlLang.addTarget(self, action: #selector(self.segmentValueChangedForLang(_:)), for: .valueChanged)
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        self.updateText()
        
    }
    
    @objc func segmentValueChangedForNoti(_ sender: AnyObject?){
        
        if segmentControlNoti.selectedIndex == 0 {
            print(Localized("on"))
        }else{
            print(Localized("off"))
        }
    }
    
    @objc func segmentValueChangedForLang(_ sender: AnyObject?){
        
        if segmentControlLang.selectedIndex == 0 {
            print("English")
        }else{
            print("عربي")
        }
        
        JSN.log("sender.selectedSegmentIndex ==>%@", segmentControlLang.selectedIndex)
        if segmentControlLang.selectedIndex == 0 {
            Language.shared.isArabic = false
            UserDefaults.standard.set(false, forKey: "ar")
        }else if segmentControlLang.selectedIndex == 1 {
            Language.shared.isArabic = true
            UserDefaults.standard.set(true, forKey: "ar")
        }
        
        DispatchQueue.async {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
            UITableView.appearance().semanticContentAttribute = .forceLeftToRight
            UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
            UITabBar.appearance().semanticContentAttribute = .forceLeftToRight

            if Language.shared.isArabic {
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
                UITableView.appearance().semanticContentAttribute = .forceRightToLeft
                UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
                UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
            }
            DispatchQueue.async {
                self.navigateToWelcomeScreen()
            }
        }
    }
    
    @objc func onTapMoreAction() {
        
    }
    
    @IBAction func btnLangSelection(_ sender: UISegmentedControl) {
            
            JSN.log("sender.selectedSegmentIndex ==>%@", sender.selectedSegmentIndex)
            if sender.selectedSegmentIndex == 0 {
                Language.shared.isArabic = false
                UserDefaults.standard.set(false, forKey: "ar")
            }else if sender.selectedSegmentIndex == 1 {
                Language.shared.isArabic = true
                UserDefaults.standard.set(true, forKey: "ar")
            }
            
            DispatchQueue.async {
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
                UITableView.appearance().semanticContentAttribute = .forceLeftToRight
                UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
                UITabBar.appearance().semanticContentAttribute = .forceLeftToRight

                if Language.shared.isArabic {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                    UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
                    UITableView.appearance().semanticContentAttribute = .forceRightToLeft
                    UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
                    UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
                }
                DispatchQueue.async {
                    self.navigateToWelcomeScreen()
                }
            }
            
            
        }
    
    @IBAction func btnNotiSelection(_ sender: UIButton) {
        isNotification = !isNotification
        sender.isSelected = (isNotification == true) ?false:true
    }
    
//    @IBAction func btnLangSelection(_ sender: UIButton) {
//
//        //        JSN.log("sender.selectedSegmentIndex ==>%@", sender.tag)
//        if sender.isSelected {
//            Language.shared.isArabic = false
//            UserDefaults.standard.set(false, forKey: "ar")
//        }else{
//            Language.shared.isArabic = true
//            UserDefaults.standard.set(true, forKey: "ar")
//        }
//
//        DispatchQueue.async {
//            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//            UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
//            UITableView.appearance().semanticContentAttribute = .forceLeftToRight
//            UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
//            UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
//
//            if Language.shared.isArabic {
//                UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
//                UITableView.appearance().semanticContentAttribute = .forceRightToLeft
//                UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
//                UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
//            }
//            DispatchQueue.async {
//                self.navigateToWelcomeScreen()
//            }
//        }
//
//
//    }
    
    
    
    func updateText() {
        if SamratGlobal.loggedInUser()?.user == nil {
            self.myAcountContainView.isHidden = true
            self.lblLogout.text = Localized("login")
        }else {
            self.myAcountContainView.isHidden = true
            self.lblLogout.text = Localized("myAccount") //"Logout"
        }
        self.lblLang.text = Localized("language")
        self.lblNotification.text = Localized("notification")
        self.lblMyAccount.text = Localized("myAccount")
        //        self.lblFaq.text = Localized("FAQs")
        self.lblContactUs.text = Localized("contactUs")
        self.lblTermsAndCondition.text = Localized("termsAndConditions")
        self.lblAboutUs.text = Localized("aboutUs")
        //        self.lblCancellationPolicy.text = Localized("cancellationPolicy")
        //        self.lblPrivacyPolicy.text = Localized("privacyPolicy")
    }
    
    
    
    //    @IBAction func onTapFaqAction(_ sender: UIControl) {
    //        let faqVc = FAQVC()
    //        self.navigationController?.pushViewController(faqVc, animated: true)
    //    }
    
    @IBAction func onTapMyAccountAction(_ sender: UIControl) {
        let myAccountvc = MyAccountVC()
        self.navigationController?.pushViewController(myAccountvc, animated: true)
    }
    
    @IBAction func onTapContactus(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ContactUsViewController") as! ContactUsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapAboutUsAction(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "1"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func onTapTermsAndConditions(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "2"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //    @IBAction func onTapCancelationPolicyAction(_ sender: UIControl) {
    //        let cancallationPolicyVC = CancallationPolicyVC()
    //        self.navigationController?.pushViewController(cancallationPolicyVC, animated: true)
    //    }
    //
    //    @IBAction func onTapPrivacyPolicyAction(_ sender: UIControl) {
    //        let cancallationPolicyVC = CancallationPolicyVC()
    //        cancallationPolicyVC.isPrivacyPolicy = true
    //        self.navigationController?.pushViewController(cancallationPolicyVC, animated: true)
    //    }
    
    @IBAction func onTapLogouAction(_ sender: UIControl) {
        if SamratGlobal.loggedInUser()?.user == nil {
            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let myAccountvc = MyAccountVC()
            self.navigationController?.pushViewController(myAccountvc, animated: true)
        }
    }
    
    
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        
        if indexPath.row == 0 {
            cell.lblTitle.text = "My Profile"
        } else if indexPath.row == 1 {
            cell.lblTitle.text = "About Us"
        } else if indexPath.row == 2 {
            cell.lblTitle.text = "Terms and Conditions"
        } else if indexPath.row == 3 {
            cell.lblTitle.text = "Contact Us"
        } else if indexPath.row == 4 {
            cell.lblTitle.text = "Rate Us"
        } else if indexPath.row == 5 {
            cell.lblTitle.text = "Share with your lovable"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
            vc.cmsType = "1"
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
            vc.cmsType = "2"
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 3 {
            let vc = self.storyboard?.instantiateViewController(identifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 4 {
        } else if indexPath.row == 5 {
        }
    }
}
