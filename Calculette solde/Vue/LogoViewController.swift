//
//  LogoViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 19/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class LogoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transition()
    }
    
    private func transition()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
             self.performSegue(withIdentifier: "segue", sender: self )
         }
    }
}
