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
        
        let colors = ["blue", "green", "yellow", "red"]
        
        // create the cards in four colors and 1 thru 13
        for n in 1...13 {
            for c in 0...3 {
                let card = Card(thisColor: colors[c], thisValue: n)
                shuffledCards.append(card)
            }
        }
        
        // create the wizards (14) & nils (0)
        for _ in 1...4 {
            for n in [0,14]{
                let card = Card(thisColor: "black", thisValue: n)
                shuffledCards.append(card)
            }
        }
    }
    
    func dealCard () -> Card {
        // picks a random card, removes it from the deck and returns it
        
        let randomNumber = Int.random(in: 0..<shuffledCards.count)
        playedCards.append(shuffledCards[randomNumber])
        playedCards.last?.playedByPlayer = 0
        
        shuffledCards.remove(at: randomNumber)
        return playedCards.last!
    }
    
}
