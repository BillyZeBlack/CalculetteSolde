//
//  ViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 29/05/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, OptionsDelegate {

    let myGlobalManager = GlobalManager()
    
    @IBOutlet weak var otherDiscountViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnAchete: CustomUIButton!
    @IBOutlet weak var lblTotalProduct: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var btnValider: CustomUIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTrash: UIButton!
    
    
    //Marks : TextField
    @IBOutlet weak var txtFldPrixDepart: CustomUiTextField!
    @IBOutlet weak var lblPrixFinal: UILabel!
    @IBOutlet weak var txtFldMaxBudget: UITextField!
    @IBOutlet weak var otherDiscountView: UIView!
    @IBOutlet weak var txtFldOtherDiscount: CustomUiTextField!
    @IBOutlet weak var lblMontantEconomise: UILabel!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var txtFldBugetMax: UITextField!
    @IBOutlet weak var stpBudgetMax: UIStepper!
    
    //Marks : sidebar
    var sidebarshowed = false

    var pourcentageDeduire = ""
    var pourcentage = 0.0
    var remise = ""
    var labelPourcentage :[String] = ["...%","5%","10%","15%",
                                      "20%","25%","30%","35%",
                                      "40%","45%","50%","55%",
                                      "60%","65%","70%","75%",
                                      "80%","85%","90%","95%","...%"]
    var totalArticle : [Double] = []
    var priceProduct : Double = 0.0
    var montantReduction : Double = 0.0
    var discountProduct : Double = 0.0
    var prixDeDepart : Double = 0.0
    var reduction : Double = 0.0
    //
    var mesArticles: Double = 0
    var limiteMaxi : Double = 0
    var choixLimite : Bool = false
    
    
                                                            /////////////////////////////////// viewDidLoad///////////////////////
    override func viewDidLoad() {
       super.viewDidLoad()
        
        self.hideKeyboard()
        view.backgroundColor = UIColor.white
        
        // Affiche le clavier
        txtFldPrixDepart.becomeFirstResponder()
        
        txtFldPrixDepart.textColor = UIColor.black
        txtFldOtherDiscount.textColor = UIColor.black
                
        lblPrixFinal.textColor = UIColor.black
        lblTotalProduct.textColor = UIColor.black
        lblMontantEconomise.textColor = UIColor.black
        lblTitle.textColor = UIColor.black
        lblPrixFinal.text = "Nouveau prix"
        lblTotalProduct.text = "Total des achats"
        
        myCollectionView.backgroundView = nil
        myCollectionView.backgroundColor = .clear
        /**
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.green.cgColor, UIColor.blue.cgColor]
        /**gradientLayer.startPoint = CGPoint(x: 0,y: 0)
        gradientLayer.startPoint = CGPoint(x: 1,y: 1)**/
        view.layer.insertSublayer(gradientLayer, at: 0)**/
  
       if myGlobalManager.myProductManager.listOfProduct.isEmpty {
        myTableView.isHidden = true
        lblMontantEconomise.isHidden = true
        btnTrash.isHidden = true
       }
    
       // Gestion de la view
        
       otherDiscountViewConstraint.constant = 1004//415
       otherDiscountView.layer.borderWidth = 2
       otherDiscountView.layer.cornerRadius = 10
       otherDiscountView.layer.shadowColor = UIColor.black.cgColor
       otherDiscountView.layer.shadowOffset = CGSize(width: 15, height: -8)
       otherDiscountView.layer.shadowOpacity = 0.7
       otherDiscountView.layer.shadowRadius = 10
        
       // change la couleur du palceholder
        txtFldPrixDepart.attributedPlaceholder = NSAttributedString(string: "ENTREZ LE PRIX INITIAL", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemYellow])
        txtFldOtherDiscount.attributedPlaceholder = NSAttributedString(string: "ENTREZ VOTRE REDUCTION", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemYellow])
        
        //Image boutons
        btnAchete.imageView?.tintColor = UIColor.darkGray
        btnValider.imageView?.tintColor = UIColor.darkGray
        
        otherDiscountView.layer.borderColor = UIColor.orange.cgColor
        
   }
    
    // me permet de faire passer l'instance de la view et de son protocole
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" , let optionView = segue.destination as? ReglagesViewController {
            optionView.delegate = self
        }
    }
    
    // conformité à "OptionDelegate"
    func getOptions(limitMax: Double, choix: Bool) {
        limiteMaxi = limitMax
        choixLimite = choix
    }
    
    
                                                                             /////////////////IBAction functions//////////////////
    @IBAction func addProductIntoListProduct(_ sender: UIButton)
    {
        if txtFldPrixDepart.text == "" {
            lblPrixFinal.text = "0.0 €"
        }
        
        if lblPrixFinal.text! == "0.0 €" && txtFldPrixDepart.text! == "" {
            
            var prixFinal = replaceString(myString: txtFldPrixDepart.text!)  // lblPrixFinal.text!
            
            if let i = prixFinal.firstIndex(of: "€") {
                prixFinal.remove(at: i)
            }
            
            if let i = prixFinal.firstIndex(of: " ") {
                prixFinal.remove(at: i)
            }
            
            guard let constant = Double (prixFinal) else { return showAlertPopup(title: "Erreur", message: "Vérifiez le prix.") }
            
            if constant == 0.0 {
                showAlertPopup(title: "Message", message: "Entrez un prix.")
            } else {
                ajouterALaListe(prixInitial: constant, prixFinal: constant, reduction: reduction)
            }
            
        } else {
            var prix : Double = 0
            let prixFinal =  replaceString(myString: txtFldPrixDepart.text!)
            
            guard let constant = Double (prixFinal) else { return showAlertPopup(title: "Erreur", message: "Vérifiez le prix.") }
            
            if reduction != 0 {
                prix = priceProduct
            } else {
                prix = constant
            }
            if constant != 0 {
                ajouterALaListe(prixInitial: constant, prixFinal: prix, reduction: reduction)
            } else {
                showAlertPopup(title: "Message", message: "Votre prix est à \"0\".")
            }
        }
    }
    
    
    @IBAction func applyOtherdiscount(_ sender: UIButton)
    {
         if txtFldPrixDepart.text != "" && txtFldOtherDiscount.text! != ""{

            let prixInit = replaceString(myString: txtFldPrixDepart.text!)
                 
            let reduc = replaceString(myString: txtFldOtherDiscount.text!)
                 
            guard let tempPrixInit = Double (prixInit) else { return showAlertPopup(title: "Erreur", message: "Vérifiez le prix.") }
            guard let tempReduc = Double (reduc) else { return showAlertPopup(title: "Erreur", message: "Vérifiez votre réduction.") }
                 
            prixDeDepart = tempPrixInit
            reduction = tempReduc
            
            if reduction <= 100 {
                calculDuPrix(prixDepart: prixDeDepart, reduction: reduction)
            } else {
                showAlertPopup(title: "Message", message: "Vérifiez votre réduction")
            }

            closeSidebar()
                                          
         } else if txtFldPrixDepart.text! == "" && txtFldOtherDiscount.text! == "" {
             closeSidebar()
         } else if txtFldPrixDepart.text! != "" && txtFldOtherDiscount.text! == ""{
            closeSidebar()
         } else {
            showAlertPopup(title: "Information", message: "Vérifiez le prix.")
        }
         
    }
    
    //Remet à zéro la reduction, à chaque modification du prix
    @IBAction func txtFldValuechanged(_ sender: Any) {
        reduction = 0
    }
    
    
    @IBAction func deleteAllArticle(_ sender: Any) {
        myGlobalManager.myProductManager.deleteallProduct()
        myTableView.reloadData()
        lblTotalProduct.text = String (myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct))+" €"
        lblMontantEconomise.text = String(myGlobalManager.myProductManager.myDiscounts(myListOfPrduct: myGlobalManager.myProductManager.listOfProduct))+" €"
        lblTotalProduct.textColor = UIColor.black
        lblMontantEconomise.isHidden = true
        btnTrash.isHidden = true
        myTableView.isHidden = true
        limiteMaxi = 0
        choixLimite = false
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
        case "...%":
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

                    
                    let prixInit = replaceString(myString: txtFldPrixDepart.text!)
                    
                    let reduc = replaceString(myString: pourcentageDeduire)
                    
                    guard let tempPrixInit = Double (prixInit) else { return showAlertPopup(title: "Erreur", message: "Vérifiez le prix.") }
                    guard let tempReduc = Double (reduc) else { return showAlertPopup(title: "Erreur", message: "Vérifiez votre réduction.") }
                    //
                    
                    //
                    prixDeDepart = tempPrixInit
                    reduction = tempReduc
                    
                    calculDuPrix(prixDepart: prixDeDepart, reduction: reduction)
                    //ajouterALaListe(prixFinal: priceProduct, reduction: reduction)
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
            cell.configure(firstPrice: product.firstPrice, finalPrice: product.finalPrice,theDiscount: product.discount)
            myCell = cell
        }
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myGlobalManager.myProductManager.deleteProduct(index: indexPath.row)
            let totalProduct = myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct)
            let totalEconomie = 0 - myGlobalManager.myProductManager.myDiscounts(myListOfPrduct: myGlobalManager.myProductManager.listOfProduct)
            lblTotalProduct.text = String(format: " %.2f", totalProduct) + " €"
            lblMontantEconomise.text = String(format: " %.2f", totalEconomie) + " €"
            if totalProduct < limiteMaxi {
                lblTotalProduct.textColor = UIColor.black
            }
            
            tableView.reloadData()
            if myGlobalManager.myProductManager.listOfProduct.isEmpty {
                myTableView.isHidden = true
                lblMontantEconomise.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Supprimer"
    }
    /**
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prixTest = myGlobalManager.myProductManager.listOfProduct[indexPath.row].finalPrice
        let reductionTest = myGlobalManager.myProductManager.listOfProduct[indexPath.row].discount
        print("prix : \(prixTest)€ \nréduction : \(reductionTest)")
    }**/
        
    
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
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func calculDuPrix(prixDepart: Double, reduction: Double)
    {
        priceProduct = prixDepart * (1 - (reduction/100))
        montantReduction = priceProduct - prixDepart
        lblPrixFinal.text = String(format: "%.2f", priceProduct) + "€"
        //ajouterALaListe(prixFinal: priceProduct, reduction: reduction)
    }
    
    
    
    private func ajouterALaListe(prixInitial: Double, prixFinal : Double, reduction : Double)
    {
        let article = MyProduct(price: prixInitial, finalPrice: prixFinal, discount: reduction)
        myGlobalManager.myProductManager.addProdcut(product: article)
        
        let totalArticle = myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct)
        
        let totalEconomise = 0 - myGlobalManager.myProductManager.myDiscounts(myListOfPrduct: myGlobalManager.myProductManager.listOfProduct)
        lblMontantEconomise.text = String(format: " %.2f", totalEconomise) + " €"

    
        if choixLimite && totalArticle >= limiteMaxi  {
            lblTotalProduct.textColor = UIColor.systemRed
        }
        
        lblPulsate()
        myTableView.reloadData()
        myTableView.isHidden = false
        lblMontantEconomise.isHidden = false
        btnTrash.isHidden = false
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
    
    private func replaceString(myString : String)-> String
    {
        let newString = myString.replacingOccurrences(of: ",", with: ".")
        return newString
    }
    
    func checkBudgetMax(budgetMax: Double, authoBudgetMax: Bool, montantMax : Double) {
        if authoBudgetMax && budgetMax >=  montantMax{
            print("Montant atteind !!!")
        }
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



