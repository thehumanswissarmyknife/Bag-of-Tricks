//
//  BagOfTricks.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class BagOfTricks {
    let numberOfTricks : Int
    var tricksPlayed : Int = 0
    var players : [Player]
    let trump : String
    var floppedTrumpCard : Card?
    let cardDeck : DeckOfCards
    
    init (theseManyTricks : Int, thisTrump : String, thesePlayers : [Player]) {
        numberOfTricks = theseManyTricks
        players = thesePlayers
        trump = thisTrump
        cardDeck = DeckOfCards()
        
        print ("BagOfTricks created")
    }
    
   
    //    MARK: main functions
    func playBag() {
        print("bagOfTricks.playBag")
        
        for n in 1...numberOfTricks {

            print("")
            print("bagOfTricks.playBag: \(n)/\(numberOfTricks)")
            print("-------------------------")
            // deal cards
            dealCards(howManyCards: n)
            
            for m in 1...n {
                // create a trick
                let thisTrick = Trick(thisTrump: trump, thesePlayers: players)
                
                // play the trick and assign the winner to a variable
                print("### trick(\(m)) ###")
                let thisWinningPlayer = thisTrick.play()
                
                // shift the players array
                shiftPlayers(thisWinningPlayer: thisWinningPlayer)
                
                // update tricksWon of the winner
                thisWinningPlayer.tricksWon += 1
                
                // update the opponents of all players
                for thisPlayer in players {
                    thisPlayer.updateOppponents(playedCards: thisTrick.cardsInTrick)
                }
            }
        }
    }
    
    //    MARK: Utilities
    func shiftPlayers(thisWinningPlayer : Player) {
        // identify the index of the winning player
        var index = 0
        
        for _ in 0..<players.count {
            if thisWinningPlayer !== players[0] {
                players.append(players.removeFirst())
            }
            else {
                break
            }
        }
        
        // shift the player-array
        for _ in 0..<index {
            
        }
        
        var playerOrder = ""
        for thisPlayer in players {
            if playerOrder == "" {
                playerOrder = thisPlayer.name
            }
            else {
                playerOrder = "\(playerOrder)-\(thisPlayer.name)"
            }
        }
        print("New Order: \(playerOrder)")
        print("")
        
    }
    
    

    func printPlayersCards(){
        for thisPlayer in players {
            var cards = "\(thisPlayer.name):"
            for thisCard in thisPlayer.cards {
                cards = "\(cards) \(thisCard.id)"
            }
            print(cards)
        }
    }
    
    // the numberOfTricks determines how many cards each player gets
    func dealCards(howManyCards : Int) {
        print("bagOfTricks.dealCards")
        
        for _ in 1...howManyCards {
            for thisPlayer in players {
                thisPlayer.cards.append(cardDeck.dealCard())
            }
        }
        
        floppedTrumpCard = cardDeck.dealCard()
        tricksPlayed += 1
        
        // print the delat cards to the console
        printPlayersCards()
        print("cards remaining: \(cardDeck.shuffledCards.count)")
        print("cards played: \(cardDeck.playedCards.count)")
        
    }
}
