//
//  ProductManager.swift
//  Calculette solde
//
//  Created by williams saadi on 04/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import Foundation
class ProductManager {
    
    var listOfProduct : [MyProduct] = []
    
    func addProdcut (product: MyProduct)
    {
        listOfProduct.append(product)
    }
    
    func deleteProduct(index: Int)
    {
        listOfProduct.remove(at: index)
    }
    
    func myCart (myListOfProduct: [MyProduct]) -> Double
    {
        var totalCart = 0.0
        
        for item in myListOfProduct {
            totalCart += item.price
        }
        
        return totalCart
    }
}