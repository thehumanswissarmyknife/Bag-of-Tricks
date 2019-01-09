//
//  DeckOfCards.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class DeckOfCards {
    var shuffledCards : [Card]
    var playedCards = [Card]()
    
    init (){
        shuffledCards = []
        
        let colors = ["Blue", "Green", "Yellow", "Red"]
        
        // create the cards in four colors and 1 thru 13
        for n in 1...13 {
            for c in 0...3 {
                let card = Card(thisColor: colors[c], thisValue: n)
                shuffledCards.append(card)
            }
        }
        
        // create the wizards (14) & nils (0)
        for _ in 1...4 {
            for n in [0,100]{
                let card = Card(thisColor: "Black", thisValue: n)
                shuffledCards.append(card)
            }
        }
        
        // shuffle those cards good!
        shuffledCards.shuffle()
        shuffledCards.shuffle()
        shuffledCards.shuffle()
    }
    
    func dealCard () -> Card {
        // picks a random card, removes it from the deck and returns it
        
        if shuffledCards.count > 0 {
            playedCards.append(shuffledCards.removeFirst())
            playedCards.last?.playedByPlayer = 10
        }
        else {
            print("no cards left")
        }
        return playedCards.last!
    }
    
}
