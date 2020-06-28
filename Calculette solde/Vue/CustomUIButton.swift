//
//  CustomUIButton.swift
//  Calculette solde
//
//  Created by williams saadi on 05/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomUIButton: UIButton {

   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        
        layer.borderWidth = 0
        //layer.cornerRadius = 10
      
        clipsToBounds = true
        //Crée un dégradé
        /**let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)**/
        
        layer.backgroundColor = UIColor.white.cgColor
    }
}
