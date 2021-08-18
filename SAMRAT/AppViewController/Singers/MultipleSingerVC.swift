//
//  MultipleSingerVC.swift
//  SAMRAT
//
//  Created by Macmini on 10/08/21.
//

import UIKit

class MultipleSingerVC: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var lblNoDataFound: UILabel!
    @IBOutlet var viewBG: UIImageView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //MARK:- Tableview Cell init
            tableView.register(UINib.init(nibName: "MusiciansTVCell", bundle: nil), forCellReuseIdentifier: "MusiciansTVCell")
            
        }
    }
    @IBOutlet weak var lblSelectedDate: UILabel!
    
    @IBOutlet weak var btnBookNow: UIButton!
    @IBOutlet weak var scrollcontentViewHeigthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var scrollview: UIScrollView!
    var getSelectedDate:Date? = nil
    var categoriesDetails:CategoriesData? = nil
    var singerObjBasedOnCat:singersObj? = nil
    var selectedSinger:[singersData] = []
    var selectedSingers:[singersData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnBookNow.setTitle(Localized("bookNow").uppercased(), for: .normal)
        scrollview.delegate = self
        scrollcontentViewHeigthConstraint.constant = 678
        tblHeightConstraint.constant = 578
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        //self.apiGetMusician()
        if getSelectedDate != nil {
            let dateformater = DateFormatter()
            dateformater.dateFormat = "dd MMM yyyy"
            self.lblSelectedDate.text = self.convertDateFormater(dateformater.string(from: getSelectedDate!), oriDateFormate: "dd MMM yyyy", requiredDateFormate: "dd MMM yyyy")
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        if (self.categoriesDetails?.id) != nil {
            
            self.apiGetSingerListBasedOnCategories()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if self.selectedSinger.count > 0 {
            tableView.reloadData()
        }
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
                        self.tableView.layoutIfNeeded()
                        self.tblHeightConstraint.constant = self.tableView.contentSize.height
                        self.scrollcontentViewHeigthConstraint.constant = self.tblHeightConstraint.constant + 100
                        
                        
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
    
    //MARK: BUTTON ACTIONS
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        if self.selectedSinger.count == 0 {
            self.view.makeToast(alertMusician)
            return
        }
        let vc = MultipleSingersMusicianbookVC()
        vc.selectedBookingDate = self.getSelectedDate
        vc.selectedSingers = self.selectedSinger
        self.navigationController?.pushViewController(vc, animated: true)
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.singerObjBasedOnCat?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MusiciansTVCell", for: indexPath) as! MusiciansTVCell
        let musicinsDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        let filterdSection = self.selectedSinger.filter({$0.id == musicinsDetails?.id ?? 0})
        if filterdSection.count > 0 {
            cell.imgSelectedStatus.isHighlighted = (filterdSection.contains(where: {$0.id == musicinsDetails?.id}))
        }else {
            cell.imgSelectedStatus.isHighlighted = false
        }
        cell.btnMoreInfo.isHidden = false
        cell.lblMusicianName.text = musicinsDetails?.name ?? ""
        cell.lblMusicanDesc.text = musicinsDetails?.description ?? ""
        let url = URL(string: musicinsDetails?.image ?? "")
        cell.imgViewmusician.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
        
        cell.btnBook.addTarget(self, action: #selector(btnBookTapped(_:)), for: .touchUpInside)
        cell.btnBook.tag = indexPath.row
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MusiciansDetailsViewController.object()
        vc.selectedSingerDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
        vc.objMultipleSinger = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBookTapped(_ sender: UIButton){
        if let cell : MusiciansTVCell = sender.superview?.superview?.superview?.superview as? MusiciansTVCell{
            
            let indexPath = tableView.indexPath(for: cell)! as IndexPath
            
            let musicinsDetails = self.singerObjBasedOnCat?.data?[indexPath.row]
            let fileteredSection = self.selectedSinger.filter({$0.id == musicinsDetails?.id})
            
            if fileteredSection.count > 0 {
                if fileteredSection.contains(where: {$0.id == musicinsDetails?.id}) {
                    self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                }else {
                    if let getMusician = musicinsDetails {
                        self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                        self.selectedSinger.append(getMusician)
                    }
                }
            }else {
                if let getMusician = musicinsDetails {
                    self.selectedSinger.removeAll(where: {$0.id == musicinsDetails?.id})
                    self.selectedSinger.append(getMusician)
                }
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        else {
            print("not click")
        }
    }
}
