import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.layer.cornerRadius = 10.0
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
            btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10.0)
            btnSubmit.clipsToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Localized("forgotPassword") //"FORGOT PASSWORD"
        self.txtEmail.placeholder = Localized("emailMobile")
        self.btnSubmit.setTitle(Localized("submit"), for: .normal)
        self.btnSubmit.setTitle(Localized("submit"), for: .selected)
        
        if Language.shared.isArabic == true {
            self.txtEmail.textAlignment = .right
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
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == true {
            self.apiForgotPwd()
        }else {
            self.showAlert(title: alert_title, message: Localized("pEnterValidEmailAddress"))
        }
    }
    //MARK:- API Calling
    //MARK:- API Get Musician List
    func apiForgotPwd() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.forgotPwd, params: ["email":self.txtEmail.text ?? ""], isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
                switch result {
                case .success(let data):
                    do {
                        guard let data = data else {return}
                        
                        let getResponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                        
                        if getResponse?.status == true {
                            let alertController = UIAlertController.init(title: app_name, message: getResponse?.message ?? "", preferredStyle: UIAlertController.Style.alert)
                            let okAction = UIAlertAction.init(title: Localized("ok"), style: UIAlertAction.Style.default) { (okAct) in
                                self.navigationController?.popToViewController(LoginViewController.object(), animated: true)
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
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
}
