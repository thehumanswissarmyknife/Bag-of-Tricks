//
//  Opponent.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 30.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class Opponent {
    let id : Int
    
    var hasYellow : Bool
    var hasBlue : Bool
    var hasRed : Bool
    var hasGreen : Bool
    
    init (thisId : Int){
        id = thisId
        hasYellow = true
        hasBlue = true
        hasRed = true
        hasGreen = true
    }
}
