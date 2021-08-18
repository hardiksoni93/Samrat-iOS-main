//
//  OnlinePaymentVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/04/21.
//

import UIKit

class OnlinePaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    func okayButtonTapped() {
        
    }
    
    func cancleButtonTapped() {
        
    }
    
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var knetContainView: UIControl!
    
    @IBOutlet var paymentContainView: UIView!
    @IBOutlet var creditCardContainVire: UIControl!
    @IBOutlet var codContainView: UIControl!
    @IBOutlet var lblBookingAmount: UILabel!
    @IBOutlet var lblTotalAmount: UILabel!
    @IBOutlet weak var tblServices: UITableView!{
        didSet {
            tblServices.register(UINib.init(nibName: "ServicesCell", bundle: nil), forCellReuseIdentifier: "ServicesCell")
        }
    }
    @IBOutlet weak var tableviewSingers: UITableView! {
        didSet {
            tableviewSingers.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "onlinePaymentMusiciansCell", bundle: nil), forCellReuseIdentifier: "onlinePaymentMusiciansCell")
        }
    }
    //    @IBOutlet var tableViewheightConstrain: NSLayoutConstraint!
    @IBOutlet var imgCashonDeliveryStatus: UIImageView!
    
    @IBOutlet var imCreditCardStatus: UIImageView!
    @IBOutlet var imgKnetStatus: UIImageView!
    @IBOutlet weak var SingersContainerView: UIView!
    @IBOutlet var musiciansContainView: UIView!
    
    @IBOutlet var lblBookingDetails: UILabel!
    
    @IBOutlet var lbldateTitle: UILabel!
    @IBOutlet var lblPaymentSummry: UILabel!
    
    @IBOutlet var lblTotalTitle: UILabel!
    @IBOutlet var lblBookingTitle: UILabel!
    @IBOutlet weak var lblOptionalExtraServices: UILabel!
    @IBOutlet var lblPaymentOptionTitle: UILabel!
    @IBOutlet var lblCashOnDelivery: UILabel!
    @IBOutlet var lblKnet: UILabel!
    @IBOutlet var lblCradit: UILabel!
    @IBOutlet var btnPay: UIButton!
    @IBOutlet var lblMusicianTitle: UILabel!
    
    var isFromCustom = false
    var isFromMultiple = false
    var getSelectedMusician:[musiciansDetails] = []
    var selectedSinger:singersData? = nil
    var geSelectedDate:Date? = nil
    var selectedSingers:[singersData] = []
    var selectedService:[serviceDetails] = []
    var settingsResponse:SettingResponse? = nil
    var serviceResponse:ServiceResponse? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.apiGetSettingDetails()
        self.apiGetServices()
        
        self.title = Localized("onlinePayment").uppercased() //"ONLINE PAYMENT"
        self.lblBookingTitle.text = Localized("bookingDetails")
        //self.lblSingerTitle.text = Localized("singerName")
        self.lblMusicianTitle.text = Localized("musicians")
        self.lbldateTitle.text = Localized("date")
        
        self.lblPaymentOptionTitle.text = Localized("paymentOptions")
        self.lblTotalTitle.text = Localized("total")
        self.lblBookingTitle.text = Localized("bookingAmount")
        self.lblPaymentOptionTitle.text = Localized("paymentOptions")
        self.lblCashOnDelivery.text = Localized("cashOndelivery")
        self.lblKnet.text = Localized("knet")
        self.lblCradit.text = Localized("creditCard")
        self.btnPay.setTitle(Localized("pay"), for: .normal)
        
        
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableviewSingers.delegate = self
        self.tableviewSingers.dataSource = self
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableviewSingers.reloadData()
        }
        self.updateBasicDetails()
        self.imgKnetStatus.isHighlighted = true
        
    }
    
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnpayAction(_ sender: UIButton) {
        self.apiPay()
    }
    
    func updateBasicDetails() {
        //self.lblSingerName.text = self.selectedSinger?.name
        self.SingersContainerView.isHidden = false
        if self.isFromCustom == true {
            if (self.getSelectedMusician.count) <= 0 {
                self.musiciansContainView.isHidden = true
            }
        }else {
            if (self.selectedSinger?.musicians?.count ?? 0) <= 0 {
                self.musiciansContainView.isHidden = true
            }
        }
        
        self.lblTotalAmount.text = (self.selectedSinger?.price ?? "") + " " + "KD"
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "dd/MM/yyyy"
        self.lblDate.text = formatter3.string(from: self.geSelectedDate ?? Date())
        
    }
    
    func apiGetServices() {
        APIManager.handler.GetRequest(url: ApiUrl.BookingServices, isLoader: false, header: nil) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.serviceResponse = try JSONDecoder().decode(ServiceResponse.self, from: getDara)
                        if self.serviceResponse?.status == true {
                            if self.serviceResponse?.booking_service != nil {
                                if (self.serviceResponse?.booking_service?.count)! > 0 {
                                    self.tblServices.delegate = self
                                    self.tblServices.dataSource = self
                                    self.tblServices.reloadData()
                                    self.paymentSummary()
                                }
                            }
                            
                        }else {
                            self.showAlert(title: app_name, message: self.settingsResponse?.message ?? commonError) {
                                
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
    
    //MARK:- TableView delegate and datasource
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        self.tableViewheightConstrain.constant = self.tableView.contentSize.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableviewSingers {
            return self.selectedSingers.count > 0 ? self.selectedSingers.count : 1
        }
        else if tableView == self.tblServices {
            return self.serviceResponse?.booking_service?.count ?? 0
        }
        else {
            return (self.isFromCustom == true) ? (self.getSelectedMusician.count) : (self.selectedSinger?.musicians?.count ?? 0)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "onlinePaymentMusiciansCell", for: indexPath) as! onlinePaymentMusiciansCell
        if tableView == self.tableviewSingers {
            if !isFromMultiple {
                let singer = self.selectedSinger
                cell.lblName.text = singer?.name
                //cell.lblDescriptioon.text = ""
            }
            else {
                let singer = self.selectedSingers[indexPath.row]
                cell.lblName.text = singer.name
                //cell.lblDescriptioon.text = ""
            }
        }
        else if tableView == self.tblServices {
            let cell = self.tblServices.dequeueReusableCell(withIdentifier: "ServicesCell", for: indexPath) as! ServicesCell
            let singer = self.serviceResponse?.booking_service?[indexPath.row]
            cell.lblServiceName.text = singer?.title ?? ""
            cell.lblNewDetail.text = singer?.description ?? ""
            cell.lblPriceTag.text = String(describing: (singer?.price)!)  + " KD"
            let filterdSection = self.selectedService.filter({$0.id == singer?.id ?? 0})
            if filterdSection.count > 0 {
                cell.imgSelection.isHighlighted = (filterdSection.contains(where: {$0.id == singer?.id}))
            }else {
                cell.imgSelection.isHighlighted = false
            }
            return cell
            
        }
        else {
            if self.isFromCustom == true {
                let musicianDetails = self.getSelectedMusician[indexPath.row]
                cell.lblName.text = musicianDetails.category_name ?? "" + " - " + (musicianDetails.name)!
                //cell.lblDescriptioon.text = ""//musicianDetails.name ?? ""
            }else {
                let musicianDetails = self.selectedSinger?.musicians?[indexPath.row]
                cell.lblName.text = musicianDetails?.category_name ?? "" + " - " + (musicianDetails?.name)!
                //cell.lblName.text = musicianDetails?.category_name ?? ""
                //cell.lblDescriptioon.text = musicianDetails?.name ?? ""
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesCell", for: indexPath)
        if tableView == tblServices {
            let service = self.serviceResponse?.booking_service?[indexPath.row]
            let filterSelection = self.selectedService.filter({$0.id == service?.id})
            if filterSelection.count > 0 {
                if filterSelection.contains(where: {$0.id == service?.id}) {
                    self.selectedService.removeAll(where: {$0.id == service?.id})
                }else {
                    if let getMusician = service {
                        self.selectedService.removeAll(where: {$0.id == service?.id})
                        self.selectedService.append(getMusician)
                    }
                }
            }else {
                if let getMusician = service {
                    self.selectedService.removeAll(where: {$0.id == service?.id})
                    self.selectedService.append(getMusician)
                }
            }
            self.paymentSummary()
            self.tblServices.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    @IBAction func onTapCashOnDelivery(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imgCashonDeliveryStatus.isHighlighted = true
    }
    
    @IBAction func onTapknetAction(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imgKnetStatus.isHighlighted = true
        
    }
    
    @IBAction func creditCardAction(_ sender: UIControl) {
        self.paymentSelectedStatus()
        self.imCreditCardStatus.isHighlighted = true
        
    }
    
    
    func paymentSelectedStatus() {
        self.imgCashonDeliveryStatus.isHighlighted = false
        self.imgKnetStatus.isHighlighted = false
        self.imCreditCardStatus.isHighlighted = false
    }
    
    //MARK:- Payment Summary SERVICE COST
    func paymentSummary() {
        
        var musicianIds = ""
        if self.isFromCustom == true {
            musicianIds = self.getSelectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
        }else {
            musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
        }
        
        var serviceIds = ""
        var strserviceArray : [String] = []
        
        for i in self.selectedService {
            strserviceArray.append(String(describing: i.id))
        }
        serviceIds = strserviceArray.joined(separator: ",")
        
        print(musicianIds)
        
        var strIds :String = ""
        if isFromMultiple {
            var strArray : [String] = []
            
            for i in self.selectedSingers {
                strArray.append(String(describing: i.id))
            }
            strIds = strArray.joined(separator: ",")
        }
        else {
            strIds = "\(String(describing: (self.selectedSinger?.id)!))"
        }
        
        let parameter = [
        "singer_id": strIds,
        "musician_ids":musicianIds,
        "is_default_musicians": isFromCustom == false ? 1 : 0  ,
        "service_ids":serviceIds == "" ? NSNull() : serviceIds as Any]  as [String : Any]
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.Paymentoption, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let responseObject = data else {return}
                    let responseDict = try JSONSerialization.jsonObject(with: (responseObject as NSData) as Data, options: .allowFragments) as AnyObject
                    print ("responseDict====\(responseDict)")
                    if let resultDic : NSDictionary = responseDict as! NSDictionary?
                    {
                        if let amount = resultDic.object(forKey: "total_amount") as? String {
                            self.lblTotalAmount.text = amount + " " + "KD"
                        }
                        
                    }
                    
//                    let bookingResponse = try? JSONDecoder().decode(createBookingObj.self, from: data)
//
//                    if bookingResponse?.status == true {
//                        let paymentvc = PaymentSuccessVC()
//                        paymentvc.getResponseMsg = bookingResponse
//                        self.navigationController?.pushViewController(paymentvc, animated: true)
//                    }else {
////                        self.showAlert(title: alert_title, message: bookingResponse?.message ?? commonError)
//                        AlertView.instance.showAlert(title: "Alert!!", message: NSAttributedString(string: bookingResponse?.message ?? commonError), alertType: .oneButton)
//                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
//                    }
                    
                    
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
    
    
    //MARK:- Checkout API Calling
    func apiPay() {
        
        var musicianIds = ""
        if self.isFromCustom == true {
            musicianIds = self.getSelectedMusician.map({"\($0.id ?? 0)"}).joined(separator: ",")
        }else {
            musicianIds = (self.selectedSinger?.musicians?.map({"\($0.id ?? 0)"}) ?? []).joined(separator: ",")
        }
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd"
        let bookingDate =  formatter3.string(from: self.geSelectedDate ?? Date())
        let parameter = [
            "singer_id":"\(self.selectedSinger?.id ?? 0)",
            "musician_ids":musicianIds,
            "booking_date":bookingDate,
            //        "start_time":"12:00:00",
            //        "end_time":"13:00:00",
            "payment_type":"cash",
            "payment_amount":self.selectedSinger?.price ?? "",
            "transaction_id":"10",
            "card_type":"master",
            "card_number":"4566",
            "card_exp_month":"10",
            "card_exp_year":"2021"]  as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.createBooking, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let bookingResponse = try? JSONDecoder().decode(createBookingObj.self, from: data)
                    
                    if bookingResponse?.status == true {
                        let paymentvc = PaymentSuccessVC()
                        paymentvc.getResponseMsg = bookingResponse
                        self.navigationController?.pushViewController(paymentvc, animated: true)
                    }else {
//                        self.showAlert(title: alert_title, message: bookingResponse?.message ?? commonError)
                        AlertView.instance.showAlert(title: "Alert!!", message: NSAttributedString(string: bookingResponse?.message ?? commonError), alertType: .oneButton)
                        AlertView.instance.alertViewDelegate = self
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
    
    
    //MARK:- Contact US API Calling
    fileprivate func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.settingsResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        if self.settingsResponse?.status == true {
                            let bookingAmount = (Double(self.selectedSinger?.price ?? "0") ?? 0) * (Double(self.settingsResponse?.settings?.minimum_booking_payment ?? "1.0") ?? 1)
                            let calculateBookingAmount = bookingAmount/100
                            //                            let calculateBookingAmount = bookingAmount/50.0
                          
                            self.lblBookingAmount.text = String(describing: Double((self.settingsResponse?.settings?.minimum_booking_payment)!)!) + " " + "KD"
                            if self.settingsResponse?.settings?.is_cod_enable == "1" {
                                self.codContainView.isHidden = false
                            }
                            
                            if self.settingsResponse?.settings?.is_online_payment_enable == "1" {
                                self.knetContainView.isHidden = false
                                self.creditCardContainVire.isHidden = false
                            }
                            
                            if self.settingsResponse?.settings?.is_cod_enable == "0" && self.settingsResponse?.settings?.is_online_payment_enable == "0" {
                                self.paymentContainView.isHidden = false
                            }
                            
                        }else {
                            self.showAlert(title: app_name, message: self.settingsResponse?.message ?? commonError) {
                                
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
