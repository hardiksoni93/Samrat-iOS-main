import UIKit
import SVProgressHUD
import KRProgressHUD
import KRActivityIndicatorView

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK:- @IBOutlets
    @IBOutlet var btnSamrat: UIButton!{
        didSet{
            btnSamrat.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var btnJalsat: UIButton!{
        didSet{
            btnJalsat.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var btnFraqShamia: UIButton!{
        didSet{
            btnFraqShamia.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "HomeTCell", bundle: nil), forCellReuseIdentifier: "HomeTCell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppConstant.shared.firstTimeHome = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.navigationItem.title = Localized("categories").uppercased() //"CATEGORIES"
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.updateTableContentInset()
        self.apiGetCategories()
        
    }
    
    func openMusicianWhenOneData(categoriesDetails:CategoriesData?){
        let controller = CatSingerListVC()
        controller.categoriesDetails = categoriesDetails
        addChild(controller)
        controller.view.frame = self.view.frame
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
//        let catSingerListVC = CatSingerListVC()
//        catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
//        self.navigationController?.pushViewController(catSingerListVC, animated: true)
    }
    
    
    func updateTableContentInset() {
        let numRows = self.tableView.numberOfRows(inSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
        
//        self.tableView.transform = CGAffineTransform (scaleX: 1,y: -1)
    }
    
    
    
    //MARK:- Table View delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoriesModel.shared.categoriesObj?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeTCell", for: indexPath) as! HomeTCell
        let categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
        cell.lblTitle.text = categoriesDetails?.name?.uppercased() ?? ""
//        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let catSingerListVC = CatSingerListVC()
        catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
        self.navigationController?.pushViewController(catSingerListVC, animated: true)
        
//        let demoGallaryVC = DemoGallaryVC()
//        self.navigationController?.pushViewController(demoGallaryVC, animated: true)
    }
    
    
    //MARK:- Get Home API
    func apiGetCategories() {
        //        SVProgressHUD.show()
        if AppConstant.shared.firstTimeHome{
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        APIManager.handler.GetRequest(url: ApiUrl.categories, isLoader: true, header: nil) { (result) in
            //            SVProgressHUD.dismiss()
            
            
            switch result {
            case .success(let data):
                do {
                    ActivityIndicatorWithLabel.shared.hideProgressView()
                    guard let data = data else {return}
                    CategoriesModel.shared.categoriesObj = nil
                    CategoriesModel.shared.categoriesObj = try? JSONDecoder().decode(CatagoriesResponse.self, from: data)
                    
                    if CategoriesModel.shared.categoriesObj?.status == true {
                        if CategoriesModel.shared.categoriesObj?.data?.count == 1{
                            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
                            self.tabBarController?.navigationItem.title = cat?.name ?? ""
                            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
                        }else{
                            self.tabBarController?.navigationItem.title = ""
                            self.tableView.reloadData()
                            self.updateTableContentInset()
                        }
                        
                    }else {
                        self.showAlert(title: app_name, message: CategoriesModel.shared.categoriesObj?.message ?? commonError)
                    }
                    
                }catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    ActivityIndicatorWithLabel.shared.hideProgressView()
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                ActivityIndicatorWithLabel.shared.hideProgressView()
                break
            }
        }
    }
    
    
}
