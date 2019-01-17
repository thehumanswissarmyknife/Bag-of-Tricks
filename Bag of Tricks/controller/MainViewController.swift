//
//  MainViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var defaults = UserDefaults.standard
    
    func updateSettings(theseSettings: Settings) {
        var settings = theseSettings
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

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
        else if segue.identifier == "goToHighScore" {
            print("going to the highscores")
            
            let destination = segue.destination as! HighScoreViewController
        }
        else if segue.identifier == "goToGame" {
            print("going to the game")
            
            let destination = segue.destination as! GameViewController
        }
    }
    
    @IBAction func btnPlayPressed(_ sender: UIButton) {
        if sender.tag == 1 {
            // play button pressed
            performSegue(withIdentifier: "goToGame", sender: self)
        }
        else if sender.tag == 2 {
            // rules button pressed
            performSegue(withIdentifier: "goToRules", sender: self)
        }
        else if sender.tag == 3 {
            // preferences button pressed
            performSegue(withIdentifier: "goToSettings", sender: self)
        }
        else if sender.tag == 4 {
            // preferences button pressed
            performSegue(withIdentifier: "goToHighScore", sender: self)
        }
    }
    

}
