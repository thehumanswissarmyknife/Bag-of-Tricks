//
//  PreferenceViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit
import AVFoundation

protocol UpdateSettings {
    func updateSettings(theseSettings : Settings)
}

class PreferenceViewController: UIViewController {
    
    @IBOutlet weak var vBtnToggleSound: UISwitch!
    @IBOutlet weak var vBtnToggleMusic: UISwitch!
    @IBOutlet weak var vBtnSortAscending: UIButton!
    @IBOutlet weak var slMusic: UISlider!
    @IBOutlet weak var slSound: UISlider!
    
    @IBOutlet weak var vBtnSortingDescending: UIButton!
    

    var defaults = UserDefaults.standard
    var soundOn : Bool = false
    var musicOn : Bool = true
    var soundVolume : Float = 0.5
    var musicVolume : Float = 0.5
    
    var sortingOrderAscending : Bool = true  // true equals 1 to 13, false is 13 to 1
    
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
    
    var audioPlayer : AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vBtnSortAscending.setTitleColor(UIColor.white, for: .selected)
        vBtnSortingDescending.setTitleColor(UIColor.white, for: .selected)
        
        if let prefSoundOn = defaults.bool(forKey: "soundOn") as? Bool {
            soundOn = prefSoundOn
        }
        if let prefSoundVolume = defaults.float(forKey: "soundVolume") as? Float {
            soundVolume = prefSoundVolume
        }
        if let prefMusicVolume = defaults.float(forKey: "musicVolume") as? Float {
            musicVolume = prefMusicVolume
        }
        if let prefMusicOn = defaults.bool(forKey: "musicOn") as? Bool {
            musicOn = prefMusicOn
        }
        
        if let prefSortingOrder = defaults.bool(forKey: "sortingOrder") as? Bool {
            sortingOrderAscending = prefSortingOrder
        }
        
        vBtnSortAscending.isSelected = sortingOrderAscending
        vBtnSortingDescending.isSelected = !sortingOrderAscending
        vBtnToggleSound.isOn = soundOn
        vBtnToggleMusic.isOn = musicOn
        slSound.isHidden = !soundOn
        slMusic.isHidden = !musicOn
        
        slMusic.value = musicVolume
        slSound.value = soundVolume

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnToggleSound(_ sender: UISwitch) {
        soundOn = sender.isOn
        slSound.isHidden = !sender.isOn
        if soundOn {
            playSound(thisSound: "cardShuffle")
        }
    }
    
    @IBAction func btnToggleMusic(_ sender: UISwitch) {
        musicOn = sender.isOn
        slMusic.isHidden = !sender.isOn
//        if let myDelegate = delegate {
            if !musicOn {
                bgMusic?.stop()
            } else {
                playMusic()
            }
//        }

    }
    @IBAction func changeSoundVolume(_ sender: UISlider) {
        soundVolume = sender.value
        playSound(thisSound: "cardShuffle")
        
    }
    
    @IBAction func changeMusicVolume(_ sender: UISlider) {
        musicVolume = sender.value
        bgMusic?.volume = musicVolume
    }
    
    @IBAction func btnPressedSortingOrder(_ sender: UIButton) {
        if sender.tag == 1 {
            sortingOrderAscending = true
            vBtnSortAscending.isSelected = true
            vBtnSortingDescending.isSelected = false
        }
        else if sender.tag == 2 {
            sortingOrderAscending = false
            vBtnSortAscending.isSelected = false
            vBtnSortingDescending.isSelected = true
            sortingOrderAscending = false
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        // saving the preferences to user defaults
        defaults.set(soundOn, forKey: "soundOn")
        defaults.set(musicOn, forKey: "musicOn")
        defaults.set(sortingOrderAscending, forKey: "sortingOrder")
        defaults.set(musicVolume, forKey: "musicVolume")
        defaults.set(soundVolume, forKey: "soundVolume")

        self.dismiss(animated: true, completion: nil)
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
            
            myPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSound(thisSound: String){
        guard let url = Bundle.main.url(forResource: thisSound, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let myPlayer = audioPlayer else { return }
            myPlayer.volume = soundVolume
            
            myPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
