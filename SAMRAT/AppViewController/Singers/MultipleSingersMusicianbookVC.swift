//
//  MultipleSingersMusicianbookVC.swift
//  SAMRAT
//
//  Created by Macmini on 12/08/21.
//

import UIKit

class MultipleSingersMusicianbookVC: UIViewController {

    @IBOutlet var viewBG : UIImageView!
    @IBOutlet var segmentOutlet: UISegmentedControl!
    @IBOutlet var segmentControl : HBSegmentedControl!
    @IBOutlet var btnBookNow: UIButton!
    
    var isSelectedDefault:Bool = true
    var selectedBookingDate : Date?
    var selectedSingers:[singersData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnBookNow.setTitle(Localized("bookNow").uppercased(), for: .normal)
        self.title = Localized("musicians").uppercased()
        
        
        self.segmentOutlet.setTitle(Localized("chooseDefault"), forSegmentAt: 0)
        self.segmentOutlet.setTitle(Localized("chooseCustom"), forSegmentAt: 1)
        self.segmentOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        
        //Custom Segment Class
        segmentControl.items = [Localized("chooseDefault"), Localized("chooseCustom")]
        segmentControl.font = UIFont.systemFont(ofSize: 14)
        segmentControl.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControl.selectedIndex = 0
        segmentControl.padding = 0
        segmentControl.addTarget(self, action: #selector(self.onSegmentValueChange(_:)), for: .valueChanged)
    }


    @IBAction func onSegmentValueChange(_ sender: UISegmentedControl) {
        if segmentControl.selectedIndex == 0 {
            print(Localized("chooseDefault"))
        }else{
            print(Localized("chooseCustom"))
        }
        isSelectedDefault = !isSelectedDefault
    }
    @IBAction func onNext(_ sender: UIButton) {
        if SamratGlobal.loggedInUser()?.user != nil {
            if self.isSelectedDefault == true {
                var singerModel = singersData()
                var musiModel : [musiciansData] = []
                for i in 0..<self.selectedSingers.count {
                    let singer = self.selectedSingers[i]
                    if singer.musicians != nil {
                        if (singer.musicians?.count)! > 0 {
                            for j in 0..<(singer.musicians?.count)! {
                                let music = (singer.musicians?[j])
                                let fileteredSection = musiModel.filter({$0.musician_category_id == music?.musician_category_id})
                                
                                if fileteredSection.count > 0 {
                                    if fileteredSection.contains(where: {$0.id == music?.id}) {
                                        musiModel.removeAll(where: {$0.musician_category_id == music?.musician_category_id})
                                    }else {
                                        if let getMusician = music {
                                            musiModel.removeAll(where: {$0.musician_category_id == music?.musician_category_id})
                                            musiModel.append(getMusician)
                                        }
                                    }
                                }else {
                                    if let getMusician = music {
                                        musiModel.removeAll(where: {$0.musician_category_id == music?.musician_category_id})
                                        musiModel.append(getMusician)
                                    }
                                }
                                //musiModel.append(contentsOf: (singer.musicians)!)
                            }
                        }
                    }
                }
                singerModel.musicians = musiModel
                print(singerModel.musicians as Any)
                
                let onlilePaymentVc = OnlinePaymentVC()
                onlilePaymentVc.isFromCustom = false
                onlilePaymentVc.selectedSinger = singerModel
                onlilePaymentVc.geSelectedDate = self.selectedBookingDate
                onlilePaymentVc.selectedSingers = self.selectedSingers
                onlilePaymentVc.isFromMultiple = true
                self.navigationController?.pushViewController(onlilePaymentVc, animated: true)
            }else {
                let musicainVc = MUSICIANSVC()
                musicainVc.getSelectedDate = self.selectedBookingDate
                musicainVc.selectedSingers = self.selectedSingers
                musicainVc.isFromMultiple = true
                self.navigationController?.pushViewController(musicainVc, animated: true)
            }
        }else {
            //            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
