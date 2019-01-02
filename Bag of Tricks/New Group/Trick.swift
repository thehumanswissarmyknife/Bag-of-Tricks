//
//  Trick.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class Trick {
    let trump : String
    var cardsInTrick = [Card]()
    var players : [Player]
    
    var winningCard : Card?
    var winningPlayer : Player?
    
    init (thisTrump : String, thesePlayers : [Player]) {
        trump = thisTrump
        players = thesePlayers
    }
    
    func returnReadibleTrickCards() -> String{
        var cards = ""
        for thisCard in cardsInTrick {
            if cards == "" {
                cards = "\(thisCard.id)"
            }
            else {
                cards = "\(cards) \(thisCard.id)"
            }
            
        }
        
        return cards
    }
    
    // play the trick: have all players play cards
    // when all cards are played, call the evaluate method
    // set the winningCard and the winningPlayer
    // returns the winningPlayer
    func play() -> Player {
        print("trick.play")
        // haev all players play their cards and add them to the cards array
        for myPlayer in players {
            let cardPlayed = myPlayer.playCard(thisTrump: trump, theseCards: cardsInTrick)
            cardsInTrick.append(cardPlayed)
        }
        
        // all players have played their cards, now evaluate.
        evaluate()
        
        // winningCard and winngPlayer are set!
        return winningPlayer!
    }
    
    // method to evaluate a trick
    func evaluate() {
        print("trick[\(returnReadibleTrickCards()), trump:\(trump)].evaluate")
        
        if cardsInTrick.count > 0 {
            winningCard = cardsInTrick[0]
            winningPlayer = players[0]
            for n in 0..<cardsInTrick.count{
                
                // if this card is a wizard
                if cardsInTrick[n].color == "black" && cardsInTrick[n].value == 14 {
                    winningCard = cardsInTrick[n]
                    winningPlayer = players[n]
                    break
                }
                
                if cardsInTrick[n].color == "black" && cardsInTrick[n].value == 0 {
                    
                } else {
                    // if the card is a trump card and the current winner is not
                    if cardsInTrick[n].color == trump && cardsInTrick[n].color != winningCard!.color{
                        winningCard = cardsInTrick[n]
                        winningPlayer = players[n]
                    }
                    
                    // cards of the same suite are calculated
                    if cardsInTrick[n].color == winningCard!.color {
                        if cardsInTrick[n].value > winningCard!.value{
                            winningCard = cardsInTrick[n]
                            winningPlayer = players[n]
                        }
                    }
                }
                
               
            }
            
            print("-------------------------------------")
            print("trick.winningCard: \(winningCard!.id)")
            print("trick.winningPlayer: \(winningPlayer!.name)")
            print("=====================================")
            
        }
    }
}
