//
//  MyUpcomingTVCell.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit

class MyUpcomingTVCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblDays: UILabel!
    @IBOutlet var lblMonthYear: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblCategoriesName: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var detailsContainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.detailsContainView.buttonShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
