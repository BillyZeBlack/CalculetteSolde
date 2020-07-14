//
//  CustomTableViewCell3.swift
//  Calculette solde
//
//  Created by williams saadi on 14/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomTableViewCell3: UITableViewCell {
    
    
    @IBOutlet weak var lblInfoDepart: UILabel!
    @IBOutlet weak var lblPrixFinal: UILabel!
    
    
    func configure(product: MyProduct)
    {
        lblInfoDepart.text = "\(product.firstPrice)€ - \(product.discount)%)"
        lblPrixFinal.text = "\(product.finalPrice)€"
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
