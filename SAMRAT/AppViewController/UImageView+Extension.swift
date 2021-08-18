//
//  UImageView+Extension.swift
//  SAMRAT
//
//  Created by Mohsin Baloch on 03/07/21.
//

import Foundation
import UIKit

extension UIImageView{
    func addBlurToView(){
        
        removeBlurToView()
        
        var blurEffect : UIBlurEffect!
        if #available(iOS 10.0, *){
            blurEffect = UIBlurEffect(style: .dark)
        }else{
            blurEffect = UIBlurEffect(style: .light)
        }
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurredEffectView.frame = self.bounds
        blurredEffectView.alpha = 0.4
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurredEffectView)
    }
    
    func removeBlurToView(){
        
        
        for subView in self.subviews{
            if subView is UIVisualEffectView{
                subView.removeFromSuperview()
            }
        }
    }
}
