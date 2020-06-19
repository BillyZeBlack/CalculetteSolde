//
//  CustomUiTextField.swift
//  Calculette solde
//
//  Created by williams saadi on 19/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomUiTextField: UITextField {
    
    
    
    

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        borderStyle = .none
        layoutIfNeeded()
        
        let border = CALayer()
        let widht = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        
        border.frame = CGRect(x: 0, y: frame.size.height - widht, width: frame.size.width, height: frame.size.height)
        border.borderWidth = widht
        
        layer.addSublayer(border)
        layer.masksToBounds = true
        
    }
    

}
