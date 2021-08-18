//
//  MUSICIANSVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class MUSICIANSVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertViewDelegate {
    func okayButtonTapped() {
        
    }
    
    func cancleButtonTapped() {
        
    }
    
    
    
//
    @IBOutlet var lblNoDataFound: UILabel!
    @IBOutlet var viewBG: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //MARK:- Tableview Header class init
            tableView.register(UINib.init(nibName: "MusicianListHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusicianListHeaderCell")
            //MARK:- Tableview Cell init
            tableView.register(UINib.init(nibName: "MusiciansTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansTVCell")
            //MARK:- Tableview Footer view init
            tableView.register(UINib.init(nibName: "MusiciansTVFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "MusiciansTVFooter")
        }
    }
    
    var selectedMusician:[musiciansDetails] = []
    var selectedSinger:singersData? = nil
    var getSelectedDate:Date? = nil
    var musicanObj:musicianRespoObj? = nil
    var selectedSingers:[singersData] = []
    var isFromMultiple = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.apiGetMusician()
        
        self.title = Localized("musicians").uppercased() //"MUSICIAN"
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: Localized("done"), style: .done, target: self, action: #selector(onLinePayment(_:)))
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y <= 0.0{
            self.viewBG.removeBlurToView()
        }else{
            self.viewBG.addBlurToView()
        }
    }
    
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
//    @objc func onLinePayment(_ sender:UIButton)
//    {
//
//        if self.selectedMusician.count <= 0 {
//            self.showAlert(title: alert_title, message: Localized("pSelectMusician"))
//            return
//        }
//        let onlinePaymentVc = OnlinePaymentVC()
//        onlinePaymentVc.isFromCustom = true
//        onlinePaymentVc.geSelectedDate = self.getSelectedDate
//        onlinePaymentVc.selectedSinger = self.selectedSinger
//        onlinePaymentVc.getSelectedMusician = self.selectedMusician
//        self.navigationController?.pushViewController(onlinePaymentVc, animated: true)
//    }
    
    
    

    
    
    //MARK:- Tableview delegate and datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.musicanObj?.data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicanObj?.data?[section].musicians?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusiciansTVCell", for: indexPath) as! MusiciansTVCell
        let musicinsDetails = self.musicanObj?.data?[indexPath.section].musicians?[indexPath.row]
        let filterdSection = self.selectedMusician.filter({$0.musician_category_id == musicinsDetails?.musician_category_id ?? 0})
        if filterdSection.count > 0 {
            cell.imgSelectedStatus.isHighlighted = (filterdSection.contains(where: {$0.id == musicinsDetails?.id}))
        }else {
            cell.imgSelectedStatus.isHighlighted = false
        }
        cell.btnMoreInfo.isHidden = true
        cell.lblMusicianName.text = musicinsDetails?.name ?? ""
        cell.lblMusicanDesc.text = musicinsDetails?.description ?? ""
        let url = URL(string: musicinsDetails?.image ?? "")
        cell.imgViewmusician.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusicianListHeader") as! MusicianListHeader
//        let musicanDetails = self.musicanObj?.data?[section]
//        headerView.lblTitle.text = musicanDetails?.name ?? ""
//        headerView.lblChoose.text = musicanDetails?.description ?? ""
//
//        return headerView
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusicianListHeaderCell") as! MusicianListHeaderCell
        let rect = CGRect(x: headerView.bounds.origin.x, y: headerView.bounds.origin.y + 220, width: headerView.bounds.width, height: headerView.bounds.height + 220)
        if section == 0{
            headerView.backgroundView = UIView(frame: rect)
        }else{
            headerView.backgroundView = UIView(frame: headerView.bounds)
        }
        
        headerView.backgroundView?.backgroundColor = UIColor.clear
        
        
        let musicanDetails = self.musicanObj?.data?[section]
        headerView.lblTitle.text = musicanDetails?.name
        headerView.lblChoose.isHidden = false
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let musicinsDetails = self.musicanObj?.data?[indexPath.section].musicians?[indexPath.row]
        let fileteredSection = self.selectedMusician.filter({$0.musician_category_id == musicinsDetails?.musician_category_id})
        
        if fileteredSection.count > 0 {
            if fileteredSection.contains(where: {$0.id == musicinsDetails?.id}) {
                self.selectedMusician.removeAll(where: {$0.musician_category_id == musicinsDetails?.musician_category_id})
            }else {
                if let getMusician = musicinsDetails {
                    self.selectedMusician.removeAll(where: {$0.musician_category_id == musicinsDetails?.musician_category_id})
                    self.selectedMusician.append(getMusician)
                }
            }
        }else {
            if let getMusician = musicinsDetails {
                self.selectedMusician.removeAll(where: {$0.musician_category_id == musicinsDetails?.musician_category_id})
                self.selectedMusician.append(getMusician)
            }
        }
        
        
        self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .none) //reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 260
        }else{
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return ((((self.musicanObj?.data?.count ?? 0)) - 1) == section) ? 60:0
//        return 60.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if ((self.musicanObj?.data?.count ?? 0) - 1) == section {
            let footerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "MusiciansTVFooter") as! MusiciansTVFooter
            footerView.onTapNextAction = {
                DispatchQueue.main.async {
                    if self.selectedMusician.count == 0{
                        AlertView.instance.showAlert(title: "Alert!!", message: NSAttributedString(string: alertMusician), alertType: .oneButton)
                        AlertView.instance.alertViewDelegate = self
                    }else{
                        let onlinePaymentVc = OnlinePaymentVC()
                        onlinePaymentVc.isFromCustom = true
                        onlinePaymentVc.isFromMultiple = self.isFromMultiple
                        onlinePaymentVc.geSelectedDate = self.getSelectedDate
                        onlinePaymentVc.selectedSinger = self.selectedSinger
                        onlinePaymentVc.selectedSingers = self.selectedSingers
                        onlinePaymentVc.getSelectedMusician = self.selectedMusician
                        self.navigationController?.pushViewController(onlinePaymentVc, animated: true)
                    }
                    
                }
            }
            return footerView
        }else {
            return UIView()
        }
    }
    
    
    
    //MARK:- API Get Musician List
    func apiGetMusician() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.getMusicians, params: [:], isLoader: true, header: nil) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
                switch result {
                case .success(let data):
                    do {
                        guard let data = data else {return}
                        
                        self.musicanObj = try? JSONDecoder().decode(musicianRespoObj.self, from: data)
                        
                        if self.musicanObj?.status == true {
                            if (self.musicanObj?.data?.count ?? 0) <= 0 {
                                self.lblNoDataFound.text = Localized("noDataFound")
                                self.lblNoDataFound.isHidden = false
                            }else {
                                self.lblNoDataFound.isHidden = true
                            }
                            self.tableView.reloadData()
                        }else {
                            self.lblNoDataFound.isHidden = true
                            self.showAlert(title: alert_title, message: UserModel.shared.objUser?.message ?? "Please check email & Password")
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

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
