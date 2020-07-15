//
//  RecapAchatViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 15/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class RecapAchatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myGlobalManager : GlobalManager!
    var myArticles : [MyProduct] = []
    var myCategories : [Categorie] = []
    var myItems  = [[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct](),[MyProduct]()]
    
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
    
    @IBAction func backToHome(_ sender: Any) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let optionView = main.instantiateViewController(withIdentifier: "optionView") as! ReglagesViewController
        self.present(optionView, animated: true, completion: nil)
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return myGlobalManager.myCategoriesManager.listCategorie[section].nom
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                totalD += item.finalPrice
            case "Vêtement":
                myItems[1].append(item)
                totalV += item.finalPrice
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
    
    
    

 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
