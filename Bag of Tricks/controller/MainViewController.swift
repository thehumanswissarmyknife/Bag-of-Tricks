//
//  MainViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController{
    
    var musicVolume : Float = 0.6
    
    var bgMusic : AVAudioPlayer? {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.bgMusic
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.bgMusic = newValue
        }
    }
   
    var defaults = UserDefaults.standard
    var musicOn = true
    
    func updateSettings(theseSettings: Settings) {
        var settings = theseSettings
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaults()
        if musicOn {
            playMusic()
        }
        
        // Do any additional setup after loading the view.

    }
    
    func loadUserDefaults(){
        
        if let prefMusicOn = defaults.bool(forKey: "musicOn") as? Bool {
            musicOn = prefMusicOn
        }
        if let prefMusicVolume = defaults.float(forKey: "musicVolume") as? Float {
            musicVolume = prefMusicVolume
        }
    }
    
    func playMusic() {
        print("playing music")
        guard let url = Bundle.main.url(forResource: "bgMusic", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            bgMusic = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            bgMusic?.numberOfLoops = -1
            
            guard let myPlayer = bgMusic else { return }
            
            myPlayer.volume = musicVolume
            
            myPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    

    /*
    // MARK: - Navigation
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoPreferences" {
            print("going to preferences")
            
            let destination = segue.destination as! PreferenceViewController
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
