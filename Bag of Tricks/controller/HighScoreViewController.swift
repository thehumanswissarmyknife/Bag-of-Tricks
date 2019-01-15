//
//  HighScoreViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 15.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController {
    var defaults = UserDefaults.standard
    var dictHighScore: [String: Int] = [:]

    @IBOutlet weak var vHighScore: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let prefHighScore = defaults.dictionary(forKey: "highScore") as? [String:Int]{
            dictHighScore = prefHighScore
        }
        var offsetY = 0
        let lName = UILabel()
        lName.text = "Player"
        lName.font = UIFont(name: "Futura", size: 25)
        lName.frame = CGRect(x: 0, y: offsetY, width: 200, height: 25)
        vHighScore.addSubview(lName)
        
        let lScore = UILabel()
        lScore.text = "Score"
        lScore.font = UIFont(name: "Futura", size: 25)
        lScore.textAlignment = NSTextAlignment.center
        lScore.frame = CGRect(x: 260, y: offsetY, width: 100, height: 25)
        vHighScore.addSubview(lScore)
        offsetY +=  30
        
        if dictHighScore.count > 0 {
            for (name, score) in dictHighScore {
                let lName = UILabel()
                lName.text = name
                lName.font = UIFont(name: "Futura", size: 25)
                lName.frame = CGRect(x: 0, y: offsetY, width: 250, height: 30)
                
                let lScore = UILabel()
                lScore.text = "\(score)"
                lScore.font = UIFont(name: "Futura", size: 25)
                lScore.textAlignment = NSTextAlignment.right
                lScore.frame = CGRect(x: 260, y: offsetY, width: 100, height: 30)
                
                vHighScore.addSubview(lName)
                vHighScore.addSubview(lScore)
                offsetY +=  35
            }
        }
        else {
            let lName = UILabel()
            lName.text = "No highscores yet"
            lName.font = UIFont(name: "Futura", size: 25)
            lName.frame = CGRect(x: Int(vHighScore.frame.width)/2 - 50, y: offsetY, width: 200, height: 30)
            vHighScore.addSubview(lName)
        }

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
    @IBAction func btnPressedBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
