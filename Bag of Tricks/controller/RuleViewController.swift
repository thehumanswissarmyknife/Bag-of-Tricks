//
//  RuleViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class RuleViewController: UIViewController {
    
    
    @IBOutlet weak var labelRules: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rules = [String]()
        
        rules.append("1. The game is played in rounds")
        rules.append("2. The number of cards is increased by one each round")
        rules.append("3. The cards have 4 colors and are numbered 1 thru 13, additionally there are 4 jokers and 4 nils")
        rules.append("4. In each trick in a round, the player with the highest card wins")
        
        var rulesText = ""
        
        for thisRule in rules {
            if rulesText == "" {
                rulesText = "\(rules[0])\n"
            }
            else {
                rulesText = "\(rulesText)\n\(thisRule)"
            }
        }
        
        labelRules.text = rulesText

        // Do any additional setup after loading the view.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
