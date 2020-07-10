//
//  CustomTableViewCell2.swift
//  Calculette solde
//
//  Created by williams saadi on 08/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class CustomTableViewCell2: UITableViewCell {

    
    @IBOutlet weak var lblNomCategorie: UILabel!
    @IBOutlet weak var imgViewCategorie: UIImageView!
    
    func configure (categorie : Categorie)
    {
        lblNomCategorie.textColor = UIColor.black
        lblNomCategorie.text = categorie.nom
        imageView?.image = UIImage(named: categorie.imageName)
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
