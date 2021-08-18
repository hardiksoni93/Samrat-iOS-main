//
//  AlertView.swift
//  Yummi
//
//  Created by Mohsin Baloch on 22/07/20.
//  Copyright © 2020 HypeTen. All rights reserved.
//

import Foundation
import UIKit

protocol AlertViewDelegate{
    func okayButtonTapped()
    
    func cancleButtonTapped()
}

class AlertView : UIView{
    static let instance = AlertView()
    
    var alertViewDelegate : AlertViewDelegate?
    
    @IBOutlet weak var okbuttonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBoxHeghtConstraint: NSLayoutConstraint!
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnCancel: UIButton!{
        didSet{
            btnCancel.addTarget(self, action: #selector(btnCancleTapped(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var btnOkay: UIButton!{
        didSet{
            btnOkay.addTarget(self, action: #selector(btnOkayTapped(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var alertView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)
        commonInit()
    }
    
    @IBAction func btnCancleTapped (_ sender: UIButton){
        parentView.removeFromSuperview()
        alertViewDelegate?.cancleButtonTapped()
    }
    
    @IBAction func btnOkayTapped (_ sender: UIButton){
        parentView.removeFromSuperview()
        alertViewDelegate?.okayButtonTapped()
    }
    
    private func commonInit(){
//        btnOkay.layer.cornerRadius = 8
//        btnOkay.layer.masksToBounds = true
        
        parentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        parentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        alertView.clipsToBounds = true
        okbuttonCenterConstraint.constant = 0
        alertBoxHeghtConstraint.constant = 365
//        alertView.layer.cornerRadius = 16
//        alertView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum AlertType{
        case twoButton
        case oneButton
    }
    
    func showAlert(title: String, message: NSAttributedString, alertType: AlertType, firstButton: String = alertButtonAgreeTitle, secondButton: String = alerButtonCancelTitle){
        self.lblTitle.text = title
        self.lblMessage.attributedText = message
        self.lblMessage.layoutIfNeeded()
        alertBoxHeghtConstraint.constant = self.lblMessage.bounds.height + 110
        
        self.btnOkay.setTitle(firstButton, for: .normal)
        self.btnCancel.setTitle(secondButton, for: .normal)
        switch alertType {
        case .twoButton:
            btnCancel.isHidden = false
            okbuttonCenterConstraint.constant = 60
            self.lblMessage.textAlignment = .left
        case .oneButton:
            btnCancel.isHidden = true
            self.btnOkay.setTitle(Localized("ok"), for: .normal)
            okbuttonCenterConstraint.constant = 0
            self.lblMessage.textAlignment = .center
        }
        UIApplication.shared.keyWindow?.addSubview(parentView)
    }
    
}
