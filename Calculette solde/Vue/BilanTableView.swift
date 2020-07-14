//
//  BilanTableView.swift
//  Calculette solde
//
//  Created by williams saadi on 14/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class BilanTableView: UITableViewController {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var myGlobalManager : GlobalManager!
    var myArticles : [MyProduct] = []
    var myCategories : [Categorie] = []
    var myItems  = [[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct]()]
    //var totalcategorie = [[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct]()]
    
    var stotal = "0"
    var totalD : Double = 0
    var totalV : Double = 0
    var totalN : Double = 0
    var totalE : Double = 0
    var totalB : Double = 0
    var totalM : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myArticles = myGlobalManager.myProductManager.listOfProduct
        myCategories = myGlobalManager.myCategoriesManager.listCategorie
        classement()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return myCategories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return (myArticles[section].categorie?.nom.count)!
        return myItems[section].count
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return myGlobalManager.myCategoriesManager.listCategorie[section].nom
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell3 {
            cell.lblInfoDepart.text = "\(myItems[indexPath.section][indexPath.row].firstPrice)€ - \(myItems[indexPath.section][indexPath.row].discount)%"
            cell.lblPrixFinal.text = String(format: " %.2f", myItems[indexPath.section][indexPath.row].finalPrice) + " €"
            myCell = cell
        }
        return myCell
    }
    
    private func classement ()
    {
        for item in myArticles {
            switch item.categorie?.nom {
            case "Divers":
                myItems[0].append(item)
            case "Vêtement":
                myItems[1].append(item)
            case "Nourriture":
                myItems[2].append(item)
            case "Electromenager":
                myItems[3].append(item)
            case "Bricolage":
                myItems[4].append(item)
            case "Multimédia":
                myItems[5].append(item)
            default :
                myItems[0].append(item)
            }
        }
    }
    

    
}
