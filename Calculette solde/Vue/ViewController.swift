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
    
    var newArticle = MyProduct(price: 00, finalPrice: 00, discount: 00, categorie: nil)
    var catSelected = Categorie(nom: "", imageName: "")
    
    @IBOutlet weak var otherDiscountViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cateViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnAchete: CustomUIButton!
    @IBOutlet weak var lblTotalProduct: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTableView2: UITableView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var btnValider: CustomUIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnCartDetail: UIButton!
    
    //Marks : TextField
    @IBOutlet weak var txtFldPrixDepart: CustomUiTextField!
    @IBOutlet weak var lblPrixFinal: UILabel!
    @IBOutlet weak var txtFldMaxBudget: UITextField!
    @IBOutlet weak var otherDiscountView: UIView!
    @IBOutlet weak var listeCategorieView: UIView!
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
    var index = 0
    //
    var mesArticles: Double = 0
    var limiteMaxi : Double = 0
    var choixLimite : Bool = false
    
    var listCategorie : [Categorie] = []
    //var listOfProduct : [MyProduct] = []
    var showNotShowCategories : Bool = false
    
    //
    var indexCat = 0
    //
                                                            /////////////////////////////////// viewDidLoad///////////////////////
    override func viewDidLoad() {
       super.viewDidLoad()
        
        listCategorie = myGlobalManager.myCategoriesManager.loadCategorieList()
        
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

  
       if myGlobalManager.myProductManager.listOfProduct.isEmpty {
        myTableView.isHidden = true
        lblMontantEconomise.isHidden = true
        btnCartDetail.isHidden = true
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
        
       cateViewConstraint.constant = 1000
       listeCategorieView.layer.borderWidth = 2
       listeCategorieView.layer.cornerRadius = 10
       listeCategorieView.layer.shadowColor = UIColor.black.cgColor
       listeCategorieView.layer.shadowOffset = CGSize(width: 15, height: -8)
       listeCategorieView.layer.shadowOpacity = 0.7
       listeCategorieView.layer.shadowRadius = 10
       listeCategorieView.layer.frame = self.view.bounds
        //listeCategorieView.layer.bounds = self.view.bounds
        
       // change la couleur du palceholder
        txtFldPrixDepart.attributedPlaceholder = NSAttributedString(string: "ENTREZ LE PRIX INITIAL", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemYellow])
        txtFldOtherDiscount.attributedPlaceholder = NSAttributedString(string: "ENTREZ VOTRE REDUCTION", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemYellow])
        
        //Image boutons
        btnAchete.imageView?.tintColor = UIColor.darkGray
        btnValider.imageView?.tintColor = UIColor.darkGray
        btnCartDetail.imageView?.tintColor = UIColor.systemYellow
        
        otherDiscountView.layer.borderColor = UIColor.orange.cgColor
        listeCategorieView.layer.borderColor = UIColor.orange.cgColor
        
   }

    
    // conformité à "OptionDelegate"
    func getOptions(limitMax: Double, choix: Bool, categories: Bool) {
        limiteMaxi = limitMax
        choixLimite = choix
        showNotShowCategories = categories
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
                let cat = Categorie(nom: "Divers", imageName: "Divers")
                newArticle = MyProduct(price: constant, finalPrice: constant, discount: reduction, categorie: cat)
                ajouterALaListe(article: newArticle)
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
                let cat = Categorie(nom: "Divers", imageName: "Divers")
                newArticle = MyProduct(price: constant, finalPrice: prix, discount: reduction, categorie: cat)
                ajouterALaListe(article: newArticle)
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
    
    var erase : Bool = false
    @IBAction func deleteAllArticles(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: "Confirmation", message: "Souhaitez-vous supprimer tous vos achats ?", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.myGlobalManager.myProductManager.deleteallProduct()
            self.lblTotalProduct.text = String (self.myGlobalManager.myProductManager.myCart(myListOfProduct: self.myGlobalManager.myProductManager.listOfProduct))+" €"
            self.lblMontantEconomise.text = String(self.myGlobalManager.myProductManager.myDiscounts(myListOfPrduct: self.myGlobalManager.myProductManager.listOfProduct))+" €"
            self.lblTotalProduct.textColor = UIColor.black
            self.lblMontantEconomise.isHidden = true
            self.btnCartDetail.isHidden = true
            self.btnTrash.isHidden = true
            self.myTableView.reloadData()
          }))

        deleteAlert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (action: UIAlertAction!) in
          //print("Handle Cancel Logic here")
          }))

        present(deleteAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func optionBtn(_ sender: Any) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let myOptionView = main.instantiateViewController(identifier: "optionView") as? ReglagesViewController
        myOptionView?.delegate = self
        myOptionView?.categorieShow = showNotShowCategories
        myOptionView?.myGlobalManager = myGlobalManager
        if choixLimite {
            myOptionView?.budgetMax = limiteMaxi
        }
        self.present(myOptionView!, animated: true, completion: nil)
        
    }
    
    @IBAction func openCartView(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let bilan = main.instantiateViewController(withIdentifier: "bilanView") as! RecapAchatViewController
        bilan.myGlobalManager = myGlobalManager
        
        
        self.present(bilan, animated: true, completion: nil)
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
        
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
            openSidebar()
            
        default:
            if txtFldPrixDepart.text != "" {
                if let i = pourcentageDeduire.firstIndex(of: "%") {
                    pourcentageDeduire.remove(at: i)
                    
                    let prixInit = replaceString(myString: txtFldPrixDepart.text!)
                    
                    let reduc = replaceString(myString: pourcentageDeduire)
                    
                    guard let tempPrixInit = Double (prixInit) else { return showAlertPopup(title: "Erreur", message: "Vérifiez le prix.") }
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
        var tableViewCount: Int?
        
        if tableView == self.myTableView {
            tableViewCount = myGlobalManager.myProductManager.listOfProduct.count
        }
        
        if tableView == self.myTableView2 {
            tableViewCount = myGlobalManager.myCategoriesManager.listCategorie.count
        }
        
        return tableViewCount!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myCell = UITableViewCell()
        
        var product = MyProduct(price: 0.0, finalPrice: 0.0, discount: 0.0, categorie: nil)
        
        if tableView == self.myTableView {
            product = myGlobalManager.myProductManager.listOfProduct[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? CustomTableViewCell {
                cell.configure(article: product)
                myCell = cell
            }
        }
        
        if tableView == self.myTableView2 && showNotShowCategories {
            let categorie = myGlobalManager.myCategoriesManager.listCategorie[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell2", for: indexPath) as? CustomTableViewCell2{
                cell.configure(categorie: categorie)
                myCell = cell
                
            }
        }
        
        if myGlobalManager.myProductManager.myCart(myListOfProduct: myGlobalManager.myProductManager.listOfProduct) < limiteMaxi {
            lblTotalProduct.textColor = UIColor.black
        }
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //erase = false
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
                btnTrash.isHidden = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.myTableView {
            
            if showNotShowCategories {
                indexCat = indexPath.row
                openCateView()
            }
        }
        
        if tableView == self.myTableView2 && showNotShowCategories {
            //Recupère la categorie
            let cat = Categorie(nom: myGlobalManager.myCategoriesManager.listCategorie[indexPath.row].nom, imageName: myGlobalManager.myCategoriesManager.listCategorie[indexPath.row].imageName)
            myGlobalManager.myProductManager.updateProduct(index: indexCat, cat: cat)
            myTableView.reloadData()
            closeCateView()
        }

    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Supprimer"
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
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func openCateView()
    {
        btnAchete.isEnabled = false
        txtFldPrixDepart.isEnabled = false
        //listeCategorieView.bounds = self.view.bounds
        //listeCategorieView.layer.frame = self.view.bounds
        cateViewConstraint.constant = 138

        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
        myCollectionView.isUserInteractionEnabled = false
    }
    
    private func closeCateView ()
    {
        txtFldPrixDepart.isEnabled = true
        btnAchete.isEnabled = true
        cateViewConstraint.constant = 1000
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
        myCollectionView.isUserInteractionEnabled = true
    }
    
    private func calculDuPrix(prixDepart: Double, reduction: Double)
    {
        priceProduct = prixDepart * (1 - (reduction/100))
        montantReduction = priceProduct - prixDepart
        lblPrixFinal.text = String(format: "%.2f", priceProduct) + "€"
        //ajouterALaListe(prixFinal: priceProduct, reduction: reduction)
    }
    

    private func ajouterALaListe(article: MyProduct)
    {
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
        btnCartDetail.isHidden = false
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
