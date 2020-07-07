//
//  RegalesViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 06/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class ReglagesViewController: UIViewController{
    
    @IBOutlet weak var txtFldBudgetMax: UITextField!
    @IBOutlet weak var categorieSwitch: UISwitch!
    @IBOutlet weak var stepperBudgetMax: UIStepper!
    
    var authoriseBudgetMax: Bool = false
    var budgetMax : Double = 0
    
    var delegate : OptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func setBudgetMax(_ sender: Any) {
        txtFldBudgetMax.text = String(stepperBudgetMax.value)
    }
    
    @IBAction func sauvegardeReglages(_ sender: Any) {
        guard let tempBudgetMax = Double (txtFldBudgetMax.text!) else { return showAlertPopup(title: "Erreur", message: "Vérifier votre montant") }
        
        budgetMax = tempBudgetMax
        if budgetMax > 0 {
            delegate?.getOptions(limitMax: budgetMax, choix: true)
            
        }
    }
    
    private func showAlertPopup(title : String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    
    

// fin de la classe
}
