//
//  Player.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

class Player {
    let name : String
    let level : String
    
    var cards = [Card]()
    var playableCards = [Card]()
    var opponents = [Opponent]()
    var suite = ""
    
    var cardsThatShoudlWinTheTrick = [Card]()
    
    // id: 0 < id < 10 for human players, id > 10 for computer players
    let id : Int
    
    var Score : Int = 0
    
    var tricksPlanned : Int = 0
    var tricksWon : Int = 0
    
    init(thisName: String, thisLevel : String, thisID: Int) {
        name = thisName
        level = thisLevel
        id = thisID
    }
    
    // sort the cards right before the card needs to be played. Index 0 should be the best card to play. Need to know the trump and cards ahve been played.
    func sortCardsToPlay(thisTrump : String, cardsPlayed : [Card]) {
        print("player[\(name)].sortCardsToPlay")
        
//        var tempCards = [Card]()
        // clear the plazyable cards
        playableCards.removeAll()
        for thisCard in cards {
            thisCard.canBePlayed = false
        }
        
        // check if there are any cards played - if not, you"re the first one
        if cardsPlayed.count>0 {
            suite = ""
            for thisCard in cardsPlayed {
                if thisCard.color != "black" {
                    suite = thisCard.color
                    break
                }
            }
            
            // identify al cards of suite and sort them into the playableCards array
            for thisCard in cards {
                if thisCard.color == suite {
                    thisCard.canBePlayed = true
                    playableCards.append(thisCard)
                }
            }
            
            // if the playableCards array is empty, it means we don't have to follow suite and all cards can be played!
            if playableCards.count == 0 {
                for thisCard in cards {
                    thisCard.canBePlayed = true
                    playableCards.append(thisCard)
                }
            }
            else {
                // add all black cards to the playableCards array
                for thisCard in cards {
                    if thisCard.color == "black" {
                        thisCard.canBePlayed = true
                        playableCards.append(thisCard)
                    }
                }
            }
            
        }
        
        // you are the first player
        else{
            
            for thisCard in cards {
                thisCard.canBePlayed = true
                playableCards.append(thisCard)
            }
            // if the remaining tricks you need to win are bigger than the number of cards that you think will will tricks
            if (tricksPlanned - tricksWon) < cardsThatShoudlWinTheTrick.count {
                // sort the cards so that the least likely to get the trick is first
                
                for thisCard in cards {
                    thisCard.canBePlayed = true
                    playableCards.append(thisCard)
                }
            }
        }
        
        // check if any card is a wizard -> means your card had no effect and theere is no suit to follow
        
        // check if the first card is a nerd, if so, check what the following card is to determine which suite to follow
        
        // if there is a suite to follow, sort all cards of that suit to the front
        
        // if you really need a
        
    }
    
    // method called to play a card
    func playCard(thisTrump : String, theseCards : [Card]) -> Card {
        
        
        // if card array is empty:
        // else if card array see, if you have the color || if you have a 14
        // decide how many tricks are possible vs tricksPlanned - tricksWon
        // play card = return the card and take it out of both
        
        sortCardsToPlay(thisTrump: thisTrump, cardsPlayed: theseCards)
        let myTestArry = playableCards
        
        let cardToPlay = playableCards[Int.random(in: 0..<playableCards.count)]
        print("player[\(name)].playCard(\(cardToPlay.id))")
        cardToPlay.playedByPlayer = id
        cards.remove(at: 0)
        return cardToPlay
        
    }
    
    // returns an array of nicely sorted and highlighted cards to display
    func displayCards() -> [String]{
        print("player[\(name)].displayCards")
        var displayCards = [""]
        
        return displayCards
    }
    
    func updateOppponents (playedCards : [Card]) {
         // after a trick is played the players can see which player played which cards to see who does not have which color any more
        
        var suite = ""
        
        // if the first card is a wizard, we can make no judgements
        if playedCards[0].value != 14 {
            // check if there was a card played that is not a nerd
            
            // the first color you find, that isn't black, is the suit to follow
            for thisCard in playedCards {
                if thisCard.color != "black" {
                    suite = thisCard.color
                    break
                }
            }
            
            for thisCard in playedCards {
                if thisCard.color != suite {
                    if thisCard.color == "black" {
                        // the player most likely has this color and just played a nerd to cover....
                    }
                    else {
                        // the player does not have the color anymore
                    }
                }
            }
            
        }
        
        
        
        
        
        
    }
    
    func initOpponents(thesePlayers : [Player]) {
        print("player.initOpponent")
        for thisPlayer in thesePlayers {
            opponents.append(Opponent(thisId: thisPlayer.id))
        }
    }
}
