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
    
    
    func configure (discount : String)
    {
        lblPourcentage.text = discount
        clipsToBounds = false
        layer.cornerRadius = 20
        layer.borderWidth = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
    }
 
}
