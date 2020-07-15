//
//  CategorieManager.swift
//  Calculette solde
//
//  Created by williams saadi on 07/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import Foundation

class CategorieManager {
    var listCategorie : [Categorie] = []
    let listeNom : [String] = ["Divers","Mode","Nourriture","Electromenager","Bricolage","Multimédia","Meuble et déco","Jardin et maison","Informatique","Téléphonie","Jeux vidéo","Sport"]
    
    func loadCategorieList () -> [Categorie]
    {
        for item in listeNom {
            let cat = Categorie(nom: item, imageName: item)
            listCategorie.append(cat)
        }
        
        return listCategorie
    }
}
