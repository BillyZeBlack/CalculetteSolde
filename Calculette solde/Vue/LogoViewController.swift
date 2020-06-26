//
//  LogoViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 25/06/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class LogoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer()
         gradientLayer.frame = self.view.bounds
         gradientLayer.colors = [UIColor.green.cgColor, UIColor.blue.cgColor]
        
         view.layer.insertSublayer(gradientLayer, at: 0)
        
        transition()
    }
    

    private func transition()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
             self.performSegue(withIdentifier: "segue2", sender: self )
         }
    }

}
