import UIKit

class CMSViewController: UIViewController {

    var cmsType = ""
    
    @IBOutlet var txtViewDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if cmsType == "1" {
            self.title = Localized("aboutUs").uppercased() //"ABOUT US"
            self.apiGetCSMResponse(url: ApiUrl.aboutUs)
        } else if cmsType == "2" {
            self.title = Localized("termsAndConditions") //"TERMS & CONDITION"
            self.apiGetCSMResponse(url: ApiUrl.termsAndCondition)
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        // Do any additional setup after loading the view.
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
                        self.txtViewDescription.attributedText = (socialMeadiResponse.data?.description ?? "").htmlAttributedString(size: 18.0, color: #colorLiteral(red: 0.9277921319, green: 0.927813828, blue: 0.9278021455, alpha: 1))
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
}
