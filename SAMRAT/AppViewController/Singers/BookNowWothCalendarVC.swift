//
//  BookNowWothCalendarVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 28/04/21.
//

import UIKit
import VACalendar

class BookNowWothCalendarVC: UIViewController {
    
//    @IBOutlet var lblChooseCustom: UILabel!
    @IBOutlet var segmentOutlet: UISegmentedControl!
//    @IBOutlet var lblChooseDefault: UILabel!
    @IBOutlet var btnSelecMusicians: UIButton!
//    @IBOutlet var btnSelectType: UIButton!
    @IBOutlet var calanderContainView: UIView!
    
    @IBOutlet var lblBookingDate: UILabel!
    
//    @IBOutlet var optionContainView: UIView!
    @IBOutlet var btnBookNow: UIButton!
    var isSelectedDefault:Bool = true
    @IBOutlet var segmentControl : HBSegmentedControl!
    
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
    
    
    @IBAction func onTapChnageTab(_ sender: UISegmentedControl) {
//        let type = (sender.selectedSegmentIndex + 1)
//        self.apiGetBookingLists()
        isSelectedDefault = !isSelectedDefault
//        self.lblNoDataFound.isHidden = true
//        if (self.upcomingResObj.count <= 0) && self.bookingType == 1 {
//            self.apiGetBookingLists()
//        }else if (self.previousResObj.count <= 0) && self.bookingType == 2 {
//            self.apiGetBookingLists()
//        }
//        self.tableView.reloadData()
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
    
    var dateArray:[Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        self.imgCustom.isHighlighted = false
        //        self.imgDefault.isHighlighted = true
        
        //        let calendar = VACalendar(calendar: defaultCalendar)
        
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
        
        self.title = Localized("bookNow").uppercased() //"BOOK NOW"
        self.lblBookingDate.text = Localized("bookingDate")
        self.btnSelecMusicians.setTitle(Localized("selectMusicians"), for: .normal)
        self.btnSelecMusicians.sendActions(for: .touchUpInside)
//        self.lblChooseDefault.text = Localized("chooseDefault")
//        self.lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0,weight: .bold)
        
//        self.lblChooseCustom.text = Localized("chooseCustom")
        
        self.segmentOutlet.setTitle(Localized("chooseDefault"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("chooseCustom"), forSegmentAt: 1)
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        //Custom Segment Class
        segmentControl.items = [Localized("chooseDefault"), Localized("chooseCustom")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), for: .valueChanged)
        
        
//        self.lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0,weight: .regular)
        self.btnBookNow.setTitle(Localized("next").uppercased(), for: .normal)
        
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        self.apiGetBookingLists()
    }
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        
        if segmentControl.selectedIndex == 0 {
            print(Localized("chooseDefault"))
        }else{
            print(Localized("chooseCustom"))
        }
        isSelectedDefault = !isSelectedDefault
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    
    @IBAction func onTapBookNowAction(_ sender: UIButton) {
        
        if SamratGlobal.loggedInUser()?.user != nil {
            if self.isSelectedDefault == true {
                let onlilePaymentVc = OnlinePaymentVC()
                onlilePaymentVc.isFromCustom = false
                onlilePaymentVc.selectedSinger = self.selectedSinger
                onlilePaymentVc.geSelectedDate = self.selectedBookingDate
                self.navigationController?.pushViewController(onlilePaymentVc, animated: true)
            }else {
                let musicainVc = MUSICIANSVC()
                musicainVc.selectedSinger = self.selectedSinger
                musicainVc.getSelectedDate = self.selectedBookingDate
                self.navigationController?.pushViewController(musicainVc, animated: true)
            }
        }else {
            //            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
//    @IBAction func onTapTypeAction(_ sender: UIButton) {
//        isSelectedDefault = !isSelectedDefault
//        if isSelectedDefault{
//            btnSelectType.isSelected = false
//            lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//            lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
//        }else{
//            btnSelectType.isSelected = true
//            lblChooseDefault.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
//            lblChooseCustom.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//        }
//    }
    
    @IBAction func onTapSelectMusicians(_ sender: UIButton) {
        self.btnBookNow.isHidden = false
//        self.optionContainView.isHidden = false
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
    
}

extension BookNowWothCalendarVC: VADayViewAppearanceDelegate {
    
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
            return UIColor.init(hexString: "CC8A65")!//.red //theamColor
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

extension BookNowWothCalendarVC: VAMonthViewAppearanceDelegate {
    
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

extension BookNowWothCalendarVC: VAMonthHeaderViewDelegate {
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


extension BookNowWothCalendarVC : VACalendarMonthDelegate {
    func monthDidChange(_ currentMonth: Date) {
        print(currentMonth)
        self.apiGetBookingLists(curentDate: currentMonth)
    }
}
extension BookNowWothCalendarVC: VACalendarViewDelegate {
    
    func selectedMsg(_ msg: String) {
        if msg == "false" {
            selectedBookingDate = nil
            self.view.makeToast(msgInvalidDateSelection)
        }
    }
    func selectedDates(_ dates: [Date]) {
        if (dates.last ?? Date()) >= Date() {
            //            calendarView.startDate = dates.last ?? Date()
            //            calendarView.selectDates([dates.last ?? Date()])
            selectedBookingDate = dates.last ?? Date()
        }else {
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
