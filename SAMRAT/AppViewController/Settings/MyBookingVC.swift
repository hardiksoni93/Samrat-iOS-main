//
//  MyBookingVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit
import KRPullLoader

class MyBookingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, KRPullLoadViewDelegate {
    
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "MyUpcomingTVCell", bundle: nil), forCellReuseIdentifier: "MyUpcomingTVCell")
        }
    }
    
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var lblNoDataFound: UILabel!
    
    @IBOutlet var segmentControl : HBSegmentedControl!
    
    var bookingType = 1
    var upcomingCurrentPage = 1
    var previousBookingPage = 1
    var upcomingTotalPage = 0
    var previousTotalPage = 0
    var upcomingResObj:[Bookings] = [Bookings]()
    var previousResObj:[Bookings] = [Bookings]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = Localized("myBookings").uppercased() //"My Booking"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        tableView.addPullLoadableView(refreshView, type: .refresh)
        let loadeMoreView = KRPullLoadView()
        loadeMoreView.delegate = self
        tableView.addPullLoadableView(loadeMoreView, type: .loadMore)
        self.apiGetBookingLists()
        
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        self.segmentOutlet.setTitle(Localized("upcoming"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("previous"), forSegmentAt: 1)
        
        //Custom Segment Class
        segmentControl.items = [Localized("upcoming"), Localized("previous")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), for: .valueChanged)
        
    }
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            print(Localized("upcoming"))
        }else{
            print(Localized("previous"))
        }
        self.bookingType = (segmentControl.selectedIndex + 1)
        //        self.apiGetBookingLists()
        self.lblNoDataFound.isHidden = true
        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
            self.apiGetBookingLists()
        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
            self.apiGetBookingLists()
        }
        self.tableView.reloadData()
    }
    @IBAction func onTapChnageTab(_ sender: UISegmentedControl) {
        self.bookingType = (sender.selectedSegmentIndex + 1)
        //        self.apiGetBookingLists()
        self.lblNoDataFound.isHidden = true
        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
            self.apiGetBookingLists()
        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
            self.apiGetBookingLists()
        }
        self.tableView.reloadData()
    }
    
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Tableview Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.bookingType == 1) ? (self.upcomingResObj.count) : (self.previousResObj.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MyUpcomingTVCell", for: indexPath) as! MyUpcomingTVCell
        if self.bookingType == 1 {
            let bookingDetails = self.upcomingResObj[indexPath.row]
            let url = URL(string: bookingDetails.singer?.image ?? "")
            cell.imgView.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
            cell.lblTitle.text = bookingDetails.singer?.name ?? ""
            cell.lblCategoriesName.text = bookingDetails.singer?.category_name ?? ""
            cell.lblDesc.text = bookingDetails.singer?.description ?? ""
            cell.lblDays.text = self.convertDateFormater(bookingDetails.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "dd")
            cell.lblMonthYear.text = self.convertDateFormater(bookingDetails.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "MMM yyyy")
            
        }else {
            let bookingDetails = self.previousResObj[indexPath.row]
            let url = URL(string: bookingDetails.singer?.image ?? "")
            cell.imgView.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
            cell.lblTitle.text = bookingDetails.singer?.name ?? ""
            cell.lblCategoriesName.text = bookingDetails.singer?.category_name ?? ""
            cell.lblDesc.text = bookingDetails.singer?.description ?? ""
            cell.lblDays.text = self.convertDateFormater(bookingDetails.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "dd")
            cell.lblMonthYear.text = self.convertDateFormater(bookingDetails.booking_date ?? "", oriDateFormate: "yyyy-MM-dd", requiredDateFormate: "MMM yyyy")
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    
    //MARK:- Pull Down refresh
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    if self.bookingType == 1 {
                        if self.upcomingCurrentPage < self.upcomingTotalPage {
                            self.upcomingCurrentPage = self.upcomingCurrentPage + 1
                            self.apiGetBookingLists()
                        }else {
                            self.tableView.reloadData()
                        }
                    }else {
                        if self.previousBookingPage < self.previousTotalPage {
                            self.previousBookingPage = self.previousBookingPage + 1
                            self.apiGetBookingLists()
                        }else {
                            self.tableView.reloadData()
                        }
                    }
                }
            default: break
            }
            return
        }
        
        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""
            
        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = ""//"Pull more. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            } else {
                pullLoadView.messageLabel.text = ""//"Release to refresh. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            }
            
        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = "Updating..."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                if self.bookingType == 1 {
                    self.upcomingResObj = []
                    self.upcomingCurrentPage = 1
                }else if self.bookingType == 2 {
                    self.previousResObj = []
                    self.previousBookingPage = 1
                }
                self.apiGetBookingLists()
            }
        }
        
    }
    
    
    //MARK:- API Calling
    //
    //MARK:- API getting Singer
    fileprivate func apiGetBookingLists() {
        let parameter = [
            "page" : (self.bookingType == 1) ? "\(self.upcomingCurrentPage)" : "\(self.previousBookingPage)",
            "type":"\(self.bookingType)"
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.getBokkings, params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getBookingObj = try JSONDecoder().decode(BookingResObj.self, from: data)
                    
                    if getBookingObj.status == true {
                        if self.bookingType == 1 {
                            self.upcomingCurrentPage = getBookingObj.cur_page ?? 0
                            self.upcomingTotalPage = getBookingObj.total_page ?? 0
                            if let getBookigs = getBookingObj.bookings {
                                self.upcomingResObj.append(contentsOf: getBookigs)
                                if self.upcomingResObj.count == 0 {
                                    self.lblNoDataFound.isHidden = false
                                }else {
                                    self.lblNoDataFound.isHidden = true
                                }
                            }
                        }else {
                            self.previousBookingPage = getBookingObj.cur_page ?? 0
                            self.previousTotalPage = getBookingObj.total_page ?? 0
                            if let getBookigs = getBookingObj.bookings {
                                self.previousResObj.append(contentsOf: getBookigs)
                                if self.previousResObj.count == 0 {
                                    self.lblNoDataFound.isHidden = false
                                }else {
                                    self.lblNoDataFound.isHidden = true
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }else {
                        self.showAlert(title: app_name, message: getBookingObj.message ?? commonError)
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
