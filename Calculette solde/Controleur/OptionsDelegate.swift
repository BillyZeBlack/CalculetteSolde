//
//  OptionsDelegate.swift
//  Calculette solde
//
//  Created by williams saadi on 07/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import Foundation

protocol OptionsDelegate {
    func getOptions(limitMax : Double, choix : Bool, categories : Bool)
}
