//
//  ViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 29/05/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {


    //Marks : TextField
    @IBOutlet weak var txtFldPrixDepart: UITextField!
    @IBOutlet weak var txtFldAutreRemise: UITextField!
    @IBOutlet weak var lblReduction: UILabel!
    @IBOutlet weak var lblPrixFinal: UILabel!
    
    
    @IBOutlet weak var btnReduction: UIButton!
    

    
    //Marks : sidebar
    //@IBOutlet weak var sidebarReglages: UIView!
    //@IBOutlet weak var sidebarConstraint: NSLayoutConstraint!
    //var sidebarshowed = false
    
    var pourcentage = 0.0
    var remise = ""
    let labelPourcentage :[String] = ["0%","5%","10%","15%",
                                      "20%","25%","30%","35%",
                                      "40%","45%","50%","55%",
                                      "60%","65%","70%","75%",
                                      "80%","85%","90%"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblPrixFinal.text = "0.0 €"
        lblReduction.text = "0.0 €"
        
        // Affiche le clavier
        txtFldPrixDepart.becomeFirstResponder()
        
        //sidebarConstraint.constant = -210
    }

    
    //IBAction functions
    @IBAction func showReglage(_ sender: Any)
    {
        /**if sidebarshowed {
            closeSidebar()
        } else {
           openSidebar()
        }
        
        sidebarshowed = !sidebarshowed**/
    }
    
    

    // MArks : CollectionView protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        labelPourcentage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var mycell = UICollectionViewCell()
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionViewCell {
            cell.configure(discount: labelPourcentage[indexPath.row])
            mycell = cell
        }
        
        return mycell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //cache le clavier
        txtFldPrixDepart.resignFirstResponder()
        var pourcentageDeduire = labelPourcentage[indexPath.row]
        if txtFldPrixDepart.text != "" {
            if let i = pourcentageDeduire.firstIndex(of: "%") {
                pourcentageDeduire.remove(at: i)
                calculPrixFinal(reduc: pourcentageDeduire)
            }
        } else {
            print("il manque le prix !!!")
        }
        

    }
    

    
    
   /** // Private function
    private func closeSidebar()
    {
        sidebarConstraint.constant = -210
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func openSidebar ()
    {
        sidebarConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }  
    }**/
    
    private func calculPrixFinal(reduc: String)
    {
        let reducAppliquee = Double(reduc)
        
        let prixDepart = Double(txtFldPrixDepart.text!)!
        
        let prixFinal: Double = prixDepart * (1 - (reducAppliquee!/100))
        
        lblPrixFinal.text = "\(prixFinal)€"
    }
    
// fin de classe
}

