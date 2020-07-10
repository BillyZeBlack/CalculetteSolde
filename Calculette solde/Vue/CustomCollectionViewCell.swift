//
//  CustomCollectionViewCell.swift
//  Calculette solde
//
//  Created by williams saadi on 02/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblPourcentage: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderColor = UIColor.orange.cgColor
        self.layer.borderWidth = 3
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func configure (discount : String)
    {
        lblPourcentage.text = discount
        /**clipsToBounds = false
        layer.cornerRadius = 20
        layer.borderWidth = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10**/
    }
    
    func lblPulsate ()
    {
    
           let pulse = CASpringAnimation(keyPath: "transform.scale")
           pulse.duration = 0.3
           pulse.toValue = 1
           pulse.fromValue = 0.95
           pulse.initialVelocity = 0.5
           pulse.damping = 1.0
           pulse.autoreverses = true
           pulse.repeatCount = 2
           
           lblPourcentage.layer.add(pulse, forKey: nil)
       }
 
}
