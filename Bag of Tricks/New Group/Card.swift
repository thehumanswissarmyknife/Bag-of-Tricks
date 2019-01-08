//
//  Card.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class Card {
    
    var color : String = ""
    var value : Int = 0
    var id : String = ""
    
    // this variable can only be changed when the card is held by a player and the trick with the leading card and trump are seen
    var canBePlayed = true
    
    // relevant, once the card is played to keep track of which player still has which color
    var playedByPlayer : Int = 0
    
    init (thisColor : String, thisValue : Int){
        
        color = thisColor
        value = thisValue
        id = "\(color)\(value)".lowercased()
    }
    
}
