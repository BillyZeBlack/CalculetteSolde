//
//  MyProduct.swift
//  Calculette solde
//
//  Created by williams saadi on 04/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import Foundation

class MyProduct  {
    var firstPrice : Double = 0.0
    var finalPrice : Double = 0.0
    var discount : Double = 0.0
    
    init(price : Double, finalPrice : Double, discount: Double) {
        self.firstPrice = price
        self.finalPrice = finalPrice
        self.discount = discount
    }
    
}
