//
//  LogoViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 19/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    
    
    @IBOutlet weak var lblNomAppli: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //lblNomAppli.textColor = UIColor.white
        transition()
        
    }
    
    private func transition()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
             self.performSegue(withIdentifier: "segue", sender: self )
         }
    }
}
