//
//  Player.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

protocol PlayerDelegate {
    func displayPlayerCards()
    func displayLastCardInTrick()
    var trump: String {get}
    var cardsInTrick : [Card] {get set}
    var playersInOrderOfTrick : [Player] {get set}
    var floppedTrumpCard : Card? {get}
}

class Player {
    
    var delegate : PlayerDelegate?
    let name : String
    
    var isHuman = false
    
    var cards = [Card]()
    var playableCards = [Card]()
    
    var colorSorting = ["Black","Yellow", "Green", "Blue", "Red"]

    // id: 0 < id < 10 for human players, id > 10 for computer players
    var id : Int = 0
    
    var score : Int = 0
    
    var tricksPlanned : Int = 0
    var tricksWon : Int = 0

    init (thisName : String, makeHuman : Bool) {
        name = thisName
        isHuman = makeHuman
    }
    

}
