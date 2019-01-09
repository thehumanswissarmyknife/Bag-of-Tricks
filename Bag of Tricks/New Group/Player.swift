//
//  Player.swift
//  myWizardClone
//
//  Created by Dennis Vocke on 26.12.18.
//  Copyright © 2018 Dennis Vocke. All rights reserved.
//

import Foundation

protocol DisplayCardsDelegate {
    func displayPlayerCards()
}

class Player {
    
    var delegate : DisplayCardsDelegate?
    let name : String
    let level : String
    var isHuman = false
    
    var cards = [Card]()
    var playableCards = [Card]()
    var opponents = [Opponent]()
    var suite = ""
    
    
    var cardsThatShoudlWinTheTrick = [Card]()
    
    // id: 0 < id < 10 for human players, id > 10 for computer players
    var id : Int
    
    var score : Int = 0
    
    var tricksPlanned : Int = 0
    var tricksWon : Int = 0
    
    init(thisName: String, thisLevel : String, thisID: Int) {
        name = thisName
        level = thisLevel
        id = thisID
    }
    
    convenience init (thisName : String, makeHuman : Bool) {
        self.init(thisName: thisName, thisLevel: "generic", thisID: 0)
        isHuman = makeHuman
        if !isHuman {
             id = Int.random(in: 1...999999)
        }
    }
    
    func sortCards() {
        cards = cards.sorted { (a, b) -> Bool in
            if ((a.color.count-1)*13)+a.value > ((b.color.count-1)*13)+b.value {
                return true
            }
            else {
                return false
            }
        }
    }
    // sort the cards right before the card needs to be played. Index 0 should be the best card to play. Need to know the trump and cards ahve been played.
    func sortCardsToPlay(thisTrump : String, cardsPlayed : [Card]) {
        print("player[\(name)].sortCardsToPlay")

        // clear the playable cards
        playableCards.removeAll()
        for thisCard in cards {
            thisCard.canBePlayed = false
        }
        
        var cardString = ""
        for thisCard in cards {
            cardString = "\(cardString) \(thisCard.id)"
        }
        print("sorting cards:\(cardString)")
        cards = cards.sorted { (a, b) -> Bool in
            if ((a.color.count-1)*13)+a.value > ((b.color.count-1)*13)+b.value {
                return true
            }
            else {
                return false
            }
        }
        
        cardString = ""
        for thisCard in cards {
            cardString = "\(cardString) \(thisCard.id)"
        }
        print("sorted cards:\(cardString)")
        
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
        
        print("\(name).playCard()")

        // if card array is empty:
        // else if card array see, if you have the color || if you have a 14
        // decide how many tricks are possible vs tricksPlanned - tricksWon
        // play card = return the card and take it out of both
        
        sortCardsToPlay(thisTrump: thisTrump, cardsPlayed: theseCards)
        
        
        let playThisCard = playableCards.randomElement()
        print("player[\(name)].playCard(\(playThisCard!.id))")
        playThisCard!.playedByPlayer = id
        
        cards = cards.filter{$0 !== playThisCard}
        
        return playThisCard!
        
    }
    
    func playThisCard(thisCardID : String) -> Card{
        
        print("\(name).playThisCard(\(thisCardID))")
        
        let cardToPlay = cards.filter{$0.id == thisCardID}[0]
        cards = cards.filter{$0 !== cardToPlay}
        
        return cardToPlay
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
    
    func calculateTricksToWin (thisTrump : String) -> Int {
        tricksPlanned = 0
        var trumpCards = [Card]()
        var wizards = [Card]()
        var likelyWinners = [Card]()
        
        for thisCard in cards {
            if thisCard.value == 14 {
                wizards.append(thisCard)
            }
            else if thisCard.color == thisTrump {
                // TODO: low trump cards should not be counted unless there are many cards in play
                trumpCards.append(thisCard)
            }
            else if thisCard.value > 11 {
                likelyWinners.append(thisCard)
            }
        }
        tricksPlanned = wizards.count + trumpCards.count + likelyWinners.count
        
        return tricksPlanned
    }
}
