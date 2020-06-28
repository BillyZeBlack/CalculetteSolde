//
//  CustomTableViewCell.swift
//  Calculette solde
//
//  Created by williams saadi on 04/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    //let myGlobalManager = GlobalManager()
    
    @IBOutlet weak var lblPriceProduct: UILabel!
    @IBOutlet weak var lblDiscountProduct: UILabel!
    
    func configure (firstPrice : Double, finalPrice: Double, theDiscount : Double)
    {
        //let myDiscount : Double = theDiscount
        
        let theDiscount = (firstPrice * theDiscount)/100
        lblPriceProduct.text = String(format: " %.2f", firstPrice) + "€  - \(theDiscount)€"//
        lblDiscountProduct.text = String(format: " %.2f", finalPrice)+"€"
        layer.cornerRadius = 10
        //String(format: " %.2f", totalEconomie) + " €"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
