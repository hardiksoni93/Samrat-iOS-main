import UIKit
import ScalingCarousel
import FSPagerView

//class CodeCell: ScalingCarouselCell {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        mainView = UIView(frame: contentView.bounds)
//        contentView.addSubview(mainView)
//        mainView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//            ])
//
//        imageContentView = UIImageView(frame: mainView.bounds)
//        contentView.addSubview(imageContentView)
////        imageContentView.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            imageContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
////            imageContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
////            imageContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
////            imageContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
////            ])
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


class GalleryViewController: UIViewController,FSPagerViewDelegate, FSPagerViewDataSource {
    @IBOutlet var containView: UIView!
    
    // MARK: - Properties (Private)
    //fileprivate var scalingCarousel: ScalingCarouselView!
    
    var gallryResponse:GalleryResponse? = nil

    @IBOutlet var pagerView: FSPagerView!{
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addCarousel()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        AppConstant.shared.firstTimeGallery = false
        pagerView.itemSize = CGSize(width: self.pagerView.frame.width , height: self.view.bounds.height - 30)

        self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
        pagerView.interitemSpacing = 5
        pagerView.backgroundColor = .clear
//        pagerView.layer.masksToBounds = true
//        pagerView.layer.cornerRadius = 10
        
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pagerView.isInfinite = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = ""
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        self.apiGetGallyList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//         if scalingCarousel != nil {
//            scalingCarousel.deviceRotated()
//         }
    }
    
    // MARK: - Configuration
    
//    private func addCarousel() {
//
//        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
//        scalingCarousel = ScalingCarouselView(withFrame: frame, andInset: 65)
//        scalingCarousel.scrollDirection = .horizontal
//        scalingCarousel.dataSource = self
//        scalingCarousel.delegate = self
//        scalingCarousel.translatesAutoresizingMaskIntoConstraints = false
//        scalingCarousel.backgroundColor = .clear
//
//        scalingCarousel.register(CodeCell.self, forCellWithReuseIdentifier: "cell")
//
//        view.addSubview(scalingCarousel)
//
//        // Constraints
//        scalingCarousel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
//        scalingCarousel.heightAnchor.constraint(equalToConstant: self.view.frame.size.height-200).isActive = true
//        scalingCarousel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        scalingCarousel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        scalingCarousel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
//    }
    
    //MARK:- FSPageView
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.gallryResponse?.data?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let galleryDetails = self.gallryResponse?.data?[index]
        let url = URL(string: galleryDetails?.image ?? "")
        cell.imageView?.kf.setImage(with:  url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.layer.masksToBounds = false
        cell.imageView?.clipsToBounds = true
        
        return cell

    }

    
    
    
    
    //MARK:- Gallery API Calling
    func apiGetGallyList() {
        if AppConstant.shared.firstTimeGallery{
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        }
        APIManager.handler.PostRequest(url: ApiUrl.get_gallery, params: [:], isLoader: true, header: nil) { (result) in
//            SVProgressHUD.dismiss()
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    self.gallryResponse = try JSONDecoder().decode(GalleryResponse.self, from: data)
                    
                    
                    if self.gallryResponse?.status == true {
                        self.pagerView.reloadData()
                        if Language.shared.isArabic == true {
                            let indxPath = IndexPath.init(row: (self.gallryResponse?.data?.count ?? 0) - 1, section: 0)
                            JSN.log("scalingCarousel ===>%@", indxPath)
//                            self.scalingCarousel.scrollToItem(at: indxPath, at: .top, animated: false)
                        }
                    }else {
                        self.showAlert(title: app_name, message: self.gallryResponse?.message ?? commonError)
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

//extension GalleryViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.gallryResponse?.data?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//
//        if let scalingCell = cell as? ScalingCarouselCell {
//            let galleryDetails = self.gallryResponse?.data?[indexPath.row]
//            var imgView = UIImageView()
//            imgView.frame = scalingCell.mainView.bounds
//            let url = URL(string: galleryDetails?.image ?? "")
//            imgView.kf.setImage(with: url, placeholder: Images.singersSplashImg, options: [.transition(.fade(0.1))], progressBlock: nil, completionHandler: nil)
////            imgView.image = UIImage(named: "13813Image1")
//            scalingCell.mainView.addSubview(imgView)
//            imgView.backgroundColor = .clear//Colors.snomo
//            imgView.contentMode = .scaleAspectFill
//            imgView.clipsToBounds = true
//            imgView.layer.cornerRadius = 20
//            scalingCell.mainView.backgroundColor = .clear//Colors.snomo
////            scalingCell.mainView.backgroundColor = .lightGray
////            scalingCell.imageContentView.frame = scalingCell.mainView.frame
////            scalingCell.imageContentView.backgroundColor = .yellow
////            scalingCell.imageContentView.image = UIImage(named: "13813Image1")
////            scalingCell.imageContentView.contentMode = .scaleAspectFit
////            scalingCell.imageContentView.clipsToBounds = true
//        }
//        DispatchQueue.main.async {
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
//        }
//
//        return cell
//    }
//}

//extension GalleryViewController: UICollectionViewDelegate {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scalingCarousel.didScroll()
//    }
//}
