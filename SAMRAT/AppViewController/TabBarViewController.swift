import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBar.items?.first?.title = Localized("home")
        self.tabBar.items?[1].title = Localized("musicians")
        self.tabBar.items?[2].title = Localized("gallery")
        self.tabBar.items?[3].title = Localized("settings")
        
    }
    
    

}
