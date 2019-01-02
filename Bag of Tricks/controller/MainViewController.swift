//
//  MainViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    func updateSettings(theseSettings: Settings) {
        var settings = theseSettings
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let player1 = Player(thisName: "Frank", thisLevel: "easy", thisID : 11)
        let player2 = Player(thisName: "Peter", thisLevel: "easy", thisID : 21)
        let player3 = Player(thisName: "Louise", thisLevel: "easy", thisID : 31)
        
        let myPlayers = [player1, player2, player3]
        print("new MainViewController")
        
        let myBagOfTricks = BagOfTricks(theseManyTricks : 5, thisTrump : "green", thesePlayers : myPlayers)
        
        
        myBagOfTricks.playBag()
    }
    

    /*
    // MARK: - Navigation
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoPreferences" {
            print("going to preferences")
            
            let destination = segue.destination as! PreferenceViewController
            
//            destination.delegate = self
        }
        
        else if segue.identifier == "goToRules" {
            print("going to the rules")
            
            let destination = segue.destination as! RuleViewController
        }
    }
    
    @IBAction func btnPlayPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            // play button pressed
        }
        else if sender.tag == 2 {
            // rules button pressed
            performSegue(withIdentifier: "goToRules", sender: self)
        }
        else if sender.tag == 3 {
            // preferences button pressed
            performSegue(withIdentifier: "goToSettings", sender: self)
        }
    }
    

}
