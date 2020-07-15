//
//  RegalesViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 06/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class ReglagesViewController: UIViewController{
    
    var myGlobalManager: GlobalManager!
    
    @IBOutlet weak var txtFldBudgetMax: UITextField!
    @IBOutlet weak var categorieSwitch: UISwitch!
    @IBOutlet weak var stepperBudgetMax: UIStepper!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnEnregistrer: CustomUIButton!
    var authoriseBudgetMax: Bool = false
    var budgetMax : Double = 0
    var categorieShow : Bool = false
    
    var delegate : OptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnEnregistrer.titleLabel?.textColor = UIColor.systemYellow
        lblTitle.textColor = UIColor.black
        
        if budgetMax != 0 {
            txtFldBudgetMax.text = "\(budgetMax)"
        }
        
        if categorieShow {
            categorieSwitch.isOn = true
        } else {
            categorieSwitch.isOn = false
        }
    }
    
    @IBAction func setBudgetMax(_ sender: UIStepper) {
        txtFldBudgetMax.text = "\(stepperBudgetMax.value)"
    }
    
    @IBAction func sauvegardeReglages(_ sender: Any) {
        if txtFldBudgetMax.text != "" {
            guard let tempBudgetMax = Double (txtFldBudgetMax.text!) else { return showAlertPopup(title: "Erreur", message: "Vérifiez votre montant") }
            budgetMax = tempBudgetMax
            if budgetMax > 0 {
                authoriseBudgetMax = true
                 delegate?.getOptions(limitMax: budgetMax, choix: authoriseBudgetMax, categories: categorieShow)
                 
            }
        } else {
            delegate?.getOptions(limitMax: budgetMax, choix: authoriseBudgetMax, categories: categorieShow)
        }
        
        
        self.dismiss(animated: true, completion: {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
        /*let main = UIStoryboard(name: "Main", bundle: nil)
        let homeView = main.instantiateViewController(withIdentifier: "homeView") as! ViewController
        //self.present(homeView, animated: true, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)*/
    }
    
    
    @IBAction func showNoShowCategories(_ sender: Any) {
        if categorieSwitch.isOn {
            categorieShow = true
        } else {
            categorieShow = false
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider){
        txtFldBudgetMax.text = "\(sender.value)"
    }
    
    private func showAlertPopup(title : String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func showAllArticle(_ sender: Any) {
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let bilanView = main.instantiateViewController(identifier: "bilanView") as? RecapAchatViewController
        bilanView?.myGlobalManager = myGlobalManager
        self.present(bilanView!, animated: true, completion: nil)
        
 
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "bilan" , let bilanView = segue.destination as? RecapAchatViewController {
            bilanView.myGlobalManager = myGlobalManager
         }
     }*/
    
    
    
    
    

// fin de la classe
}
