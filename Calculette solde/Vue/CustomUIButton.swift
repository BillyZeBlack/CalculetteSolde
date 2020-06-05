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
    
    // Création d'une animation
    /**func pulsate () {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.toValue = 1
        pulse.fromValue = 0.95
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        
        layer.add(pulse, forKey: nil)
    }**/

}
