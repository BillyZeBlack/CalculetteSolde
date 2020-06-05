//
//  ViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 29/05/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var lblTotalProduct: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        
        lblPrixFinal.text = "0.0 €"
        //lblReduction.text = "0.0 €"
        lblTotalProduct.text = "0.0 €"
        
        if myGlobalManager.myProductManager.listOfProduct.isEmpty {
            myTableView.isHidden = true
        }
        
        // Affiche le clavier
        txtFldPrixDepart.becomeFirstResponder()
        
        //sidebarConstraint.constant = -210
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    let myGlobalManager = GlobalManager()

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
    var labelPourcentage :[String] = ["+","5%","10%","15%",
                                      "20%","25%","30%","35%",
                                      "40%","45%","50%","55%",
                                      "60%","65%","70%","75%",
                                      "80%","85%","90%","+"]
    var totalArticle : [Double] = []
    var priceProduct : Double = 0.0
    var discountProduct : Double = 0.0
   

    
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
    
    @IBAction func addProductIntoListProduct(_ sender: UIButton)
    {
        let myProduct = MyProduct(price: priceProduct, discount: discountProduct)
        myGlobalManager.myProductManager.addProdcut(product: myProduct)
        myTableView.isHidden = false
        
        var totalProduct: Double = 0.0
        for item in myGlobalManager.myProductManager.listOfProduct {
            totalProduct += item.price
        }
        lblTotalProduct.text = String(format: " %.2f", totalProduct) + " €"
        myTableView.reloadData()
    }
    

    // Marks : CollectionView protocol
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
        //txtFldPrixDepart.resignFirstResponder()
        var pourcentageDeduire = labelPourcentage[indexPath.row]
        if pourcentageDeduire != "+" {
            if txtFldPrixDepart.text != "" {
                if let i = pourcentageDeduire.firstIndex(of: "%") {
                    pourcentageDeduire.remove(at: i)
                    calculPrixFinal(reduc: pourcentageDeduire)
                }
            } else {
                print("il manque le prix !!!")
            }
        } else {
            labelPourcentage = ["1%","2%","3%","4%","5%","6%","7%","8%","9%","10%",
                                "11%","12%","13%","14%","15%","16%","17%","18%","19%","20%",
                                "21%","22%","23%","24%","25%","26%","27%","28%","29%","30%",
                                "31%","32%","33%","34%","35%","36%","37%","38%","39%","40%",
                                "41%","42%","43%","44%","45%","46%","47%","48%","49%","50%",
                                "51%","52%","53%","54%","55%","56%","57%","58%","59%","60%",
                                "61%","62%","63%","64%","65%","66%","67%","68%","69%","70%",
                                "71%","72%","73%","74%","75%","76%","77%","78%","79%","80%",
                                "81%","82%","83%","84%","85%","86%","87%","88%","89%","90%",
                                "91%","92%","93%","94%","95%","96%","97%","98%","99%"]
            
            collectionView.reloadData()
        }
    }
    
    //Marks : TableView Protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myGlobalManager.myProductManager.listOfProduct.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = UITableViewCell()
        let product = myGlobalManager.myProductManager.listOfProduct[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? CustomTableViewCell {
            cell.configure(thePrice: product.price, theDiscount: product.discount)
            myCell = cell
        }
        
        return myCell
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
        
        lblPrixFinal.text = String(format: " %.2f", prixFinal) + " €"
        //lblPrixFinal.text = "\(prixFinal)€"
        
        priceProduct = prixFinal
        discountProduct = reducAppliquee!

    }
    
    private func showAlertPopup()
    {
        //var pourcentagePerso = ""
        var test = ""
        
        let alert = UIAlertController(title: "Pourcentage de réduction", message: "Entrez votre pourcentage", preferredStyle: .alert)
        
        alert.addTextField { (txtPourcentage) in
            txtPourcentage.text = ""
            
            /**if let doubleValue = Double(txtPourcentage.text!) {
                pourcentagePerso = doubleValue
            }**/
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            test = txtPourcentage.text!
            self.calculPrixFinal(reduc: test)
            //pourcentagePerso = Double(txtPourcentage.text)
        }
        self.present(alert, animated: true)
        
    }
    
// fin de classe
}

extension UIViewController {
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target:  self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
}

