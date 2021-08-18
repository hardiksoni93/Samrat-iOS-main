//
//  CatSingerListVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 03/05/21.
//

import UIKit
import VACalendar
import Toast_Swift
class CatSingerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var viewBG : UIImageView!
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var segmentControl : HBSegmentedControl!
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "SingerTVCell", bundle: nil), forCellReuseIdentifier: "SingerTVCell")
        }
    }
    
    @IBOutlet var lblNoDataFound: UILabel!

    @IBOutlet weak var calendarDateView: UIView!
    @IBOutlet var btnBookNow: UIButton!
    @IBOutlet var calanderContainView: UIView!
    @IBOutlet var lblBookingDate: UILabel!
    
    var selectedSinger:singersData? = nil
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    var calendarView: VACalendarView!
    var selectedBookingDate : Date?
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .short,weekDayTextColor: .black, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    
    @IBOutlet weak var monthHeaderView: VAMonthHeaderView!{
        didSet {
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "LLLL"
            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: UIImage.init(named: "left-arrow")!,
                nextButtonImage: UIImage.init(named: "right-arrow")!,
                dateFormatter: dateFormate
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }
    
    
    var categoriesDetails:CategoriesData? = nil
    var singerObjBasedOnCat:singersObj? = nil
    var settingsResponse:SettingResponse? = nil
    var dateArray:[Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.title = Localized("singersList").uppercased() //"SINGERS"
        calendarDateView.isHidden = true
        self.tableView.isHidden = false
        AppConstant.shared.firstTimeCat = false
        self.title = self.categoriesDetails?.name?.uppercased() ?? ""
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SAMRAT_CATBG") ?? UIImage())
        self.tableView.backgroundColor = UIColor.clear

        self.tableView.delegate = self
        self.tableView.dataSource = self
        if (self.categoriesDetails?.id) != nil {
            updateTableContentInset()
            self.apiGetSingerListBasedOnCategories()
        }
        self.segmentOutlet.isHidden = true
        self.segmentControl.isHidden = true
        self.segmentOutlet.setTitle(Localized("Single Singer"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("Multiple Singers"), forSegmentAt: 1)
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        //Custom Segment Class
        segmentControl.items = [Localized("Single Singer"), Localized("Multiple Singers")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        segmentControl.addTarget(self, action: #selector(self.onSegmentValueChange(_:)), for: .valueChanged)
        //MARK: CALENDAR VIEW SETUP
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyy"
        
        let startDate = Date()
        
        var dateComponent = DateComponents()
        dateComponent.month = 12
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: startDate)
        
        let cal = Calendar.current
        let compo = cal.dateComponents([.year, .month], from: Date())
        let startOfMonth = cal.date(from: compo)! as Date
       
        print(startOfMonth)
        
        let calendar = VACalendar(
            startDate: startDate,
            endDate: futureDate,
            calendar: defaultCalendar
        )
        calendarView = VACalendarView(frame: .zero, calendar: calendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .single
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        calendarView.monthViewAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        
        //Restrict Date
        
        let endavailables = futureDate!
        
        
        let components = Calendar.current.dateComponents([.day], from: startOfMonth, to: endavailables)
        let numberOfDays = components.day ?? 0
        let dates = (0...numberOfDays).compactMap {
            return Calendar.current.date(byAdding: .day, value: $0, to: startOfMonth)
        }
        
        let availability = DaysAvailability.some(dates)
        
        calendarView.setAvailableDates(availability)
        
        
        self.calanderContainView.addSubview(calendarView)
        self.monthHeaderView.backgroundColor = #colorLiteral(red: 0.8430671096, green: 0.5282273293, blue: 0.3670781851, alpha: 0.5) //Colors.snomoTransparant
        
        self.apiGetSettingDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if segmentControl.selectedIndex == 1 {
            if calendarView.frame == .zero {
                calendarView.frame = CGRect(
                    x: self.calanderContainView.bounds.origin.x,
                    y: self.calanderContainView.bounds.origin.y + 10,
                    width: self.calanderContainView.bounds.width - 20,
                    height: self.calanderContainView.bounds.height - 20
                )
                calendarView.setup()
                self.view.layoutIfNeeded()
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
                            
                            
                            if self.settingsResponse?.settings?.multiple_singer_booking == "1" {
                                self.segmentOutlet.isHidden = false
                                self.segmentControl.isHidden = false
                                //self.tableView.isHidden = true
                                //self.calendarDateView.isHidden = false
                                
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
    
    //MARK:- API GET BOOKINGS
    func apiGetBookingLists(curentDate: Date = Date()) {
        let parameter = [
            "page" : "1",
            "type":"1"
        ] as [String : Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let dateString : String = dateFormatter.string(from: curentDate)
        print(dateString)
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.getBokkingsDates + "=\(dateString)", params: parameter, isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getBookingObj = try JSONDecoder().decode(BookingResObj.self, from: data)
                    
                    if getBookingObj.status == true {
                        
                        self.dateArray.removeAll()
                        if (getBookingObj.data) != nil {
                            var supl : [(Date, [VADaySupplementary])] =  []
                            for i in 0..<(getBookingObj.data?.count)! {
                                let obj = (getBookingObj.data?[i])!
                                if obj.booking_date != nil {
                                    print(obj.booking_date as Any)
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                    let dateobj = dateFormatter.date(from: (obj.booking_date)!)
                                    if dateobj != nil {
                                        print(dateFormatter.string(from: dateobj!))
                                        self.dateArray.append(dateobj!)
                                        supl.append(((dateobj)!,[VADaySupplementary.bottomDots([.blue])]))
                                    }
                                }
                            }
                            if self.dateArray.count > 0 {
                                DispatchQueue.main.async {
                                    self.calendarView.setSupplementaries(supl)
                                    
                                    //self.calendarView.selectDates(self.dateArray)
                                    
                                }
                            }
                        }
                        else {
                            self.showAlert(title: app_name, message: getBookingObj.message ?? commonError)
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
    
    //MARK: BUTTON ACTIONS
    @IBAction func onNext(_ sender: UIButton) {
        if selectedBookingDate == nil {
            //showToastMessage(strMessage: msgSelectDate)
            self.view.makeToast(msgSelectDate)
//            let str = "To confirm the reservation, an amount of 50 KD must be paid, which will be returned in case of disagreement. \n \u{2022} In case of cancelation , we must be notified at least 24 hours before the concert, \n and there will be a 5% deduction of the total amount. \n \u{2022} An SMS message will be sent within 24 hours to confirm your order, with a link to pay the full amount."
//                showThemeAlert(msgTitle: alertTitle, msg: str) { issucess in
//                    print(issucess)
//                }
            return
        }
        let vc = MultipleSingerVC()
        vc.getSelectedDate = self.selectedBookingDate
        vc.categoriesDetails = self.categoriesDetails
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func onSegmentValueChange(_ sender: UISegmentedControl) {
        if segmentControl.selectedIndex == 0 {
            self.calendarDateView.isHidden = true
            self.tableView.isHidden = false
        }else{
            self.calendarDateView.isHidden = false
            self.tableView.isHidden = true
            self.apiGetBookingLists()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0{
            self.viewBG.removeBlurToView()
        }else{
            self.viewBG.addBlurToView()
        }
    }
    
    //MARK:- Tableview delegate and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.singerObjBasedOnCat?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SingerTVCell", for: indexPath) as! SingerTVCell
        let singerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        cell.lblTitle.text = singerDetails?.name
        cell.lblDecription.text = singerDetails?.description
        let url = URL(string: singerDetails?.image ?? "")
        cell.imageViewProduct.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        cell.btnBook.tag = indexPath.row
//        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton){
        let vc = MusiciansDetailsViewController.object()
        vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MusiciansDetailsViewController.object()
        vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    
    
    func updateTableContentInset() {
//        let numRows = self.tableView.numberOfRows(inSection: 0)
//        var contentInsetTop = self.tableView.bounds.size.height
//        for i in 0..<numRows {
//            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
//            contentInsetTop -= rowRect.size.height
//            if contentInsetTop <= 0 {
//                contentInsetTop = 0
//                break
//            }
//        }
//        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
        
//        self.tableView.transform = CGAffineTransform (scaleX: 1,y: -1)
//        tableView.setContentOffset(.zero, animated: true)
        
    }
    
    //MARK:- Get singer list based on categories
    func apiGetSingerListBasedOnCategories() {
//        SVProgressHUD.show()
        let parameter = [
            "category_id" : "\(self.categoriesDetails?.id ?? 0)"
        ] as [String : Any]
        if AppConstant.shared.firstTimeCat{
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        
        APIManager.handler.PostRequest(url: ApiUrl.singer, params: parameter, isLoader: true, header: nil) { (result) in
//            SVProgressHUD.dismiss()
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.singerObjBasedOnCat = try? JSONDecoder().decode(singersObj.self, from: data)
                    
                    if self.singerObjBasedOnCat?.status == true {
                        if (self.singerObjBasedOnCat?.data?.count ?? 0) <= 0 {
                            self.lblNoDataFound.text = Localized("noDataFound")
                            self.lblNoDataFound.isHidden = false
                            self.tableView.separatorColor = UIColor.clear
                        }else {
                            self.lblNoDataFound.isHidden = true
                        }
                        self.tableView.reloadData()
                        self.updateTableContentInset()
                    }else {
                        self.showAlert(title: app_name, message: self.singerObjBasedOnCat?.message ?? commonError)
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

extension CatSingerListVC: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return .lightGray//UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .white
        default:
            return .white
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return UIColor.init(hexString: "CC8A65")! //theamColor
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .square
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
    
}

extension CatSingerListVC: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 10.0
    }
    
    func rightInset() -> CGFloat {
        return 10.0
    }
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .black
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
    
}

extension CatSingerListVC: VAMonthHeaderViewDelegate {
    func currentmonthdate(date: Date) {
        print(date)
        self.apiGetBookingLists(curentDate: date)
    }
    
    
    func didTapNextMonth() {
        calendarView.nextMonth()
    }
    
    func didTapPreviousMonth() {
        calendarView.previousMonth()
    }
    
}

extension CatSingerListVC : VACalendarMonthDelegate {
    func monthDidChange(_ currentMonth: Date) {
        print(currentMonth)
        self.apiGetBookingLists(curentDate: currentMonth)
    }
}
extension CatSingerListVC: VACalendarViewDelegate {
    
    func selectedMsg(_ msg: String) {
        if msg == "false" {
            selectedBookingDate = nil
            self.view.makeToast(msgInvalidDateSelection)
        }
    }
    
    func selectedDates(_ dates: [Date]) {
        if (dates.last ?? Date()) >= Date() {
            
                        //calendarView.startDate = dates.last ?? Date()
            //            calendarView.selectDates([dates.last ?? Date()])
            selectedBookingDate = dates.last ?? Date()
            print("found data")
        }else {
            print("false")
            //            calendarView.startDate =  Date()
            //            selectedBookingDate = Date()
        }
        JSN.log("selected date ===>%@", (dates.last ?? Date()) > Date())
        // self.navigationController?.popViewController(animated: true)
    }
    
    func selectedDate(_ date: Date) {
        JSN.log("selected date ===>%@", date)
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let strdt :String = dateFormatter.string(from: date)
        print(strdt)
        let dt : Date = dateFormatter.date(from: strdt)!
        
        let strcurrent :String = dateFormatter.string(from: Date())
        print(strcurrent)
        let currentdt :Date = dateFormatter.date(from: strcurrent)!
        
        if dt < currentdt {
            print("false selection")
            return
        }
        if dt >= currentdt {

            selectedBookingDate = date
            print("if")
        }else {
            print("else")
            
        }
        
    }
    
    
    
    
}

