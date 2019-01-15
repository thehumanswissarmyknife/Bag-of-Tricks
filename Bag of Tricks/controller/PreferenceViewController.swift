//
//  PreferenceViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

protocol UpdateSettings {
    func updateSettings(theseSettings : Settings)
}

class PreferenceViewController: UIViewController {
    
    @IBOutlet weak var vBtnToggleSound: UISwitch!
    @IBOutlet weak var vBtnToggleMusic: UISwitch!
    @IBOutlet weak var vBtnSortAscending: UIButton!
    
    @IBOutlet weak var vBtnSortingDescending: UIButton!
    
    
    var defaults = UserDefaults.standard
    var soundOn : Bool = false
    var musicOn : Bool = true
    var sortingOrder : Bool = true  // true equals 1 to 13, false is 13 to 1
    
   
    var mySettings = Settings()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vBtnSortAscending.setTitleColor(UIColor.white, for: .selected)
        vBtnSortingDescending.setTitleColor(UIColor.white, for: .selected)
        
        if let prefSoundOn = defaults.bool(forKey: "soundOn") as? Bool {
            soundOn = prefSoundOn
        }
        if let prefMusicOn = defaults.bool(forKey: "musicOn") as? Bool {
            musicOn = prefMusicOn
        }
        if let prefSortingOrder = defaults.bool(forKey: "sortingOrder") as? Bool {
            sortingOrder = prefSortingOrder
        }
        
        vBtnSortAscending.isSelected = sortingOrder
        vBtnSortingDescending.isSelected = !sortingOrder
        vBtnToggleSound.isOn = soundOn
        vBtnToggleMusic.isOn = musicOn
        
        

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnToggleSound(_ sender: UISwitch) {
        soundOn = sender.isOn
    }
    @IBAction func btnToggleMusic(_ sender: UISwitch) {
        musicOn = sender.isOn
    }
    
    @IBAction func btnPressedSortingOrder(_ sender: UIButton) {
        if sender.tag == 1 {
            sortingOrder = true
            vBtnSortAscending.isSelected = true
            vBtnSortingDescending.isSelected = false
        }
        else if sender.tag == 2 {
            sortingOrder = false
            vBtnSortAscending.isSelected = false
            vBtnSortingDescending.isSelected = true
            sortingOrder = false
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        // saving the preferences to user defaults
        defaults.set(soundOn, forKey: "soundOn")
        defaults.set(musicOn, forKey: "musicOn")
        defaults.set(sortingOrder, forKey: "sortingOrder")

        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
