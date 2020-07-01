//
//  CustomTableViewCell.swift
//  Calculette solde
//
//  Created by williams saadi on 04/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

        
    @IBOutlet weak var lblPriceProduct: UILabel!
    @IBOutlet weak var lblDiscountProduct: UILabel!
    
    func configure (firstPrice : Double, finalPrice: Double, theDiscount : Double)
    {
        lblPriceProduct.textColor = UIColor.black
        lblDiscountProduct.textColor = UIColor.black
        
        let theDiscount = String(format: "%.2f",(firstPrice * theDiscount)/100)
        lblPriceProduct.text = String(format: " %.2f", firstPrice) + "€  - \(theDiscount)€"//
        lblDiscountProduct.text = String(format: " %.2f", finalPrice)+"€"
        layer.cornerRadius = 10
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
