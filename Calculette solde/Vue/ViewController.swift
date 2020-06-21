//
//  ViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 29/05/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var otherDiscountViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnAchete: CustomUIButton!
    @IBOutlet weak var lblTotalProduct: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var btnValider: CustomUIButton!

    
    //Marks : TextField
    @IBOutlet weak var txtFldPrixDepart: CustomUiTextField!
    @IBOutlet weak var lblPrixFinal: UILabel!
    @IBOutlet weak var txtFldMaxBudget: UITextField!
    @IBOutlet weak var otherDiscountView: UIView!
    @IBOutlet weak var txtFldOtherDiscount: CustomUiTextField!
    
    
    //Marks : sidebar
    var sidebarshowed = false
    
   
    
    
    var pourcentageDeduire = ""
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
    var prixDeDepart : Double = 0.0
    var reduction : Double = 0.0
    
    let myGlobalManager = GlobalManager()
    
    override func viewDidLoad() {
       super.viewDidLoad()
        myCollectionView.backgroundView = nil
        myCollectionView.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.green.cgColor]
        /**gradientLayer.startPoint = CGPoint(x: 0,y: 0)
        gradientLayer.startPoint = CGPoint(x: 1,y: 1)**/
        view.layer.insertSublayer(gradientLayer, at: 0)
  
       self.hideKeyboard()
       
       lblPrixFinal.text = "0.0 €"
       lblTotalProduct.text = "0.0 €"
       
       if myGlobalManager.myProductManager.listOfProduct.isEmpty {
           myTableView.isHidden = false//true
       }
       
       // Affiche le clavier
       txtFldPrixDepart.becomeFirstResponder()
        
       // Gestion de la view
       otherDiscountViewConstraint.constant = 1004//415
       otherDiscountView.layer.borderWidth = 2
       otherDiscountView.layer.cornerRadius = 10
       otherDiscountView.layer.shadowColor = UIColor.black.cgColor
       otherDiscountView.layer.shadowOffset = CGSize(width: 15, height: -8)
       otherDiscountView.layer.shadowOpacity = 0.7
       otherDiscountView.layer.shadowRadius = 10
        
   }
    
    
                                                                             /////////////////IBAction functions//////////////////
    @IBAction func addProductIntoListProduct(_ sender: UIButton)
    {
        if lblPrixFinal.text! != "0.0 €" {
            var prixFinal = lblPrixFinal.text!
            
            if let i = prixFinal.firstIndex(of: "€") {
                prixFinal.remove(at: i)
            }
            
            guard let constant = Double (prixFinal) else { return showAlertPopup(title: "Erreur", message: "Une erreur s'est produite.") }
            ajouterALaListe(prixFinal: constant, reduction: reduction)
        } else {
            let prixFinal = txtFldPrixDepart.text!
            
            guard let constant = Double (prixFinal) else { return showAlertPopup(title: "Erreur", message: "Une erreur s'est produite.") }
            ajouterALaListe(prixFinal: constant, reduction: reduction)
        }
    }
    
    
    @IBAction func applyOtherdiscount(_ sender: UIButton)
    {
        if txtFldPrixDepart.text!.isEmpty && txtFldOtherDiscount.text!.isEmpty {
            closeSidebar()
        } else {
            let prixInitial = txtFldPrixDepart.text!
            guard let tempPrxInit = Double (prixInitial) else { return showAlertPopup(title: "Erreur", message: "Le prix de départ n'est pas valide.")}
            
            if txtFldOtherDiscount.text!.isEmpty {
                txtFldOtherDiscount.text = "0.0"
            }
            
            let reducPerso = txtFldOtherDiscount.text!
            guard let tempReducPerso = Double (reducPerso) else { return showAlertPopup(title: "Erreur", message: "La réduction n'est pas valide.") }
            
            if tempReducPerso <= 100 {
                prixDeDepart = tempPrxInit
                reduction = tempReducPerso
                
                calculDuPrix(prixDepart: prixDeDepart, reduction: reduction)
                
            } else {
                showAlertPopup(title: "Erreur", message: "Vérifiez votre réduction")
            }

            btnAchete.isEnabled = true
            closeSidebar()
        }
    }

                                                                       ///////////////////////////// Marks : CollectionView protocol//////////////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        labelPourcentage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var mycell = UICollectionViewCell()
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionViewCell {
            cell.configure(discount: labelPourcentage[indexPath.row])
            mycell = cell
        }
        
                
        collectionView.layer.borderWidth = 0
        
        return mycell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pourcentageDeduire = labelPourcentage[indexPath.row]
        
        switch pourcentageDeduire {
        case "+":
            /**labelPourcentage = ["-","1%","2%","3%","4%","5%","6%","7%","8%","9%","10%",
            "11%","12%","13%","14%","15%","16%","17%","18%","19%","20%",
            "21%","22%","23%","24%","25%","26%","27%","28%","29%","30%",
            "31%","32%","33%","34%","35%","36%","37%","38%","39%","40%",
            "41%","42%","43%","44%","45%","46%","47%","48%","49%","50%",
            "51%","52%","53%","54%","55%","56%","57%","58%","59%","60%",
            "61%","62%","63%","64%","65%","66%","67%","68%","69%","70%",
            "71%","72%","73%","74%","75%","76%","77%","78%","79%","80%",
            "81%","82%","83%","84%","85%","86%","87%","88%","89%","90%",
            "91%","92%","93%","94%","95%","96%","97%","98%","99%","-"]
            collectionView.reloadData()**/
            openSidebar()
            
        case "-":
            labelPourcentage = ["+","5%","10%","15%",
            "20%","25%","30%","35%",
            "40%","45%","50%","55%",
            "60%","65%","70%","75%",
            "80%","85%","90%","+"]
            collectionView.reloadData()
            
        default:
            if txtFldPrixDepart.text != "" {
                if let i = pourcentageDeduire.firstIndex(of: "%") {
                    pourcentageDeduire.remove(at: i)
                    //calculPrixFinal(reduc: pourcentageDeduire)
                    let prixInit = txtFldPrixDepart.text!
                    let reduc = pourcentageDeduire
                    guard let tempPrixInit = Double (prixInit) else { return showAlertPopup(title: "Erreur", message: "Vérifiez votre prix.") }
                    guard let tempReduc = Double (reduc) else { return showAlertPopup(title: "Erreur", message: "Vérifiez votre réduction.") }
                    
                    prixDeDepart = tempPrixInit
                    reduction = tempReduc
                    
                    calculDuPrix(prixDepart: prixDeDepart, reduction: reduction)
                }
            } else {
                showAlertPopup(title: "Information", message: "Entrez un prix.")
                pourcentageDeduire = ""
            }
        }
    }
    
                                                                         /////////////////////////////////////Marks : TableView Protocol////////////////////////////////////
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myGlobalManager.myProductManager.deleteProduct(index: indexPath.row)
            let totalProduct = myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct)
            lblTotalProduct.text = String(format: " %.2f", totalProduct) + " €"
            tableView.reloadData()
        }
    }
        
    
                                                                   /////////////////////////////////////////////////////////// Private function//////////////////////////////////
    private func closeSidebar()
    {
        txtFldPrixDepart.isEnabled = true
        btnAchete.isEnabled = true
        
        otherDiscountViewConstraint.constant = 1004//414
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        txtFldOtherDiscount.text = ""
    }
    
    private func openSidebar ()
    {
        btnAchete.isEnabled = false
        txtFldPrixDepart.isEnabled = false
        txtFldOtherDiscount.text = ""
        otherDiscountViewConstraint.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func calculDuPrix(prixDepart: Double, reduction: Double)
    {
        priceProduct = prixDepart * (1 - (reduction/100))
        lblPrixFinal.text = String(format: "%.2f", priceProduct) + "€"
        //ajouterALaListe(prixFinal: priceProduct, reduction: reduction)
    }
    
    private func ajouterALaListe(prixFinal : Double, reduction : Double)
    {
        let article = MyProduct(price: prixFinal, discount: reduction)
        myGlobalManager.myProductManager.addProdcut(product: article)
        
        let totalArticle = myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct)

        lblPulsate()
        myTableView.reloadData()
        myTableView.isHidden = false
        lblTotalProduct.text = String(format: " %.2f", totalArticle) + " €"
        updateLabel()
        priceProduct = 0.0
        self.reduction = 0.0
        
    }
    
    private func updateLabel()
    {
        txtFldPrixDepart.text = ""
        lblPrixFinal.text = "0.0 €"
        
    }
    
    private func showAlertPopup(title : String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        closeSidebar()
    }
    
    private func lblPulsate ()
    {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.toValue = 1
        pulse.fromValue = 0.95
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        
        lblTotalProduct.layer.add(pulse, forKey: nil)
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
