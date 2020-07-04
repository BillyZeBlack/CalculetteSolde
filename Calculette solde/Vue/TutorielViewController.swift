//
//  TutorielViewController.swift
//  Calculette solde
//
//  Created by williams saadi on 01/07/2020.
//  Copyright © 2020 williams saadi. All rights reserved.
//

import UIKit

class TutorielViewController: UIViewController {

    @IBOutlet weak var lblTextRGPD: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnCGU(_ sender: Any) {
        lblTextRGPD.text = "Conditions d'utilisation\n1. Conditions\nEn accédant à notre application, Soldes faciles, vous acceptez d'être lié par ces conditions d'utilisation, toutes les lois et réglementations applicables, et convenez que vous êtes responsable du respect de toutes les lois locales applicables. Si vous n'êtes pas d'accord avec l'une de ces conditions, il vous est interdit d'utiliser ou d'accéder à Soldes faciles. Les documents contenus dans Soldes faciles sont protégés par les lois sur les droits d'auteur et les marques applicables.\n2. Utilisez la licence\nIl est permis de télécharger temporairement une copie de Soldes faciles par appareil pour une visualisation transitoire personnelle et non commerciale uniquement. Il s'agit de l'octroi d'une licence, et non d'un transfert de titre, et sous cette licence, vous ne pouvez pas:\n modifier ou copier le matériel ; utiliser le matériel à des fins commerciales ou pour toute exposition publique (commerciale ou non commerciale); tenter de décompiler ou de désosser tout logiciel contenu dans Soldes faciles ; supprimer tout copyright ou autres mentions de propriété du matériel; ou transférer le matériel à une autre personne ou \"mettre en miroir\" le matériel sur tout autre serveur.\nCette licence prendra automatiquement fin si vous violez l'une de ces restrictions et pourra être résiliée par Williams SAADI à tout moment. En mettant fin à votre consultation de ces documents ou à la résiliation de cette licence, vous devez détruire tous les documents téléchargés en votre possession, que ce soit au format électronique ou imprimé.\n3. Déni de responsabilité\nLes documents contenus dans Soldes faciles sont fournis «tels quels». Williams SAADI ne donne aucune garantie, expresse ou implicite, et rejette et annule par la présente toutes les autres garanties, y compris, sans limitation, les garanties implicites ou les conditions de qualité marchande, d'adéquation à un usage particulier, ou la non-violation de la propriété intellectuelle ou toute autre violation des droits.\nDe plus, Williams SAADI ne garantit ni ne fait aucune déclaration concernant l'exactitude, les résultats probables ou la fiabilité de l'utilisation des documents sur son site Web ou autrement liés à ces documents ou sur tout site lié à Soldes faciles.\n4. Limitations\nEn aucun cas, Williams SAADI ou ses fournisseurs ne seront responsables des dommages (y compris, sans limitation, des dommages pour perte de données ou de profit, ou en raison d'une interruption de l'activité) résultant de l'utilisation ou de l'impossibilité d'utiliser Soldes faciles, même si Williams SAADI ou un représentant autorisé de Williams SAADI a été informé oralement ou par écrit de la possibilité de tels dommages. Étant donné que certaines juridictions n'autorisent pas les limitations des garanties implicites ou les limitations de responsabilité pour les dommages indirects ou accessoires, ces limitations peuvent ne pas s'appliquer à vous.\n5. Précision des matériaux\nLes documents apparaissant dans Soldes faciles peuvent comprendre des erreurs techniques, typographiques ou photographiques. Williams SAADI ne garantit pas que les documents de Soldes faciles sont exacts, complets ou à jour. Williams SAADI peut apporter des modifications aux documents contenus dans Soldes faciles à tout moment sans préavis. Cependant, Williams SAADI ne s'engage pas à mettre à jour le matériel.\n6. Liens\nWilliams SAADI n'a pas examiné tous les sites liés à son application et n'est pas responsable du contenu de ces sites liés. L'inclusion de tout lien n'implique pas l'approbation par Williams SAADI du site. L'utilisation d'un tel site Web lié est aux risques et périls de l'utilisateur.\n7. Modifications\nWilliams SAADI peut réviser ces conditions de service pour son application à tout moment sans préavis. En utilisant Soldes faciles, vous acceptez d'être lié par la version alors en vigueur de ces conditions d'utilisation.\n8. Loi applicable\nCes termes et conditions sont régis et interprétés conformément aux lois de la France et vous vous soumettez irrévocablement à la compétence exclusive des tribunaux de cet État ou lieu."
    }
    
    @IBAction func btnPC(_ sender: Any) {
        lblTextRGPD.text = "Politique de confidentialité \nVotre vie privée est importante. Ma politique, est de respecter votre vie privée concernant toute information collectée auprès de vous via l’application, Soldes faciles.\nNous ne demandons des informations personnelles que lorsque nous en avons vraiment besoin pour fournir un service. Elles sont collectées par des moyens justes et légaux, avec votre connaissance et votre consentement. Vous êtes également informé sur les raisons de la collecte, pourquoi nous les collectons et comment elles seront utilisées.\nVos informations ne seront conservées que le temps nécessaire pour vous fournir le service demandé. Les données stockées, seront protégées selon des moyens commercialement acceptables pour empêcher la perte et le vol, ainsi que l'accès, la divulgation, la copie, l'utilisation ou la modification non autorisés.\nAucune information d'identification personnelle ne sera divulguée publiquement ou avec des tiers, sauf lorsque la loi l'exige.\nCette application peut créer un lien vers des sites externes que nous ne gérons pas. Veuillez noter que nous n'avons aucun contrôle sur le contenu et les pratiques de ces sites, et ne pouvons pas accepter la responsabilité de leurs politiques de confidentialité respectives.\nVous êtes libre de refuser notre demande de vos informations personnelles, étant entendu que certains de vos services ne pourront être fournis.\nVotre utilisation continue de notre application sera considérée comme une acceptation des pratiques en matière de confidentialité et d'informations personnelles. Si vous avez des questions sur la façon dont les données des utilisateurs et les informations personnelles sont traitées, n'hésitez pas à nous contacter.\nCette politique entre en vigueur le 6 juillet 2020."
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation*/
  
    

}
