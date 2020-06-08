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
        
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
    }
}
