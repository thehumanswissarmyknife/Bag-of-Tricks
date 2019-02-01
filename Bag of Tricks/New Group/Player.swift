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
    var trump: String {get}
    var cardsInTrick : [Card] {get}
    var playersInOrderOfTrick : [Player] {get}
}

class Player {
    
    var delegate : PlayerDelegate?
    let name : String
    let level : String
    var isHuman = false
    
    var cards = [Card]()
    var playableCards = [Card]()
    var opponents = [Opponent]()
    var suite = ""
    
    var defaults = UserDefaults.standard
    var sortingOrderAscending : Bool = true
    
    var sortBlueValue : Int = 4
    var sortRedValue : Int = 3
    var sortGreenValue : Int = 5
    var sortYellowValue : Int = 6
    var sortBlackValue : Int = 0
    
    var colorSorting = ["Black","Yellow", "Green", "Blue", "Red"]
    
    var blueCards = [Card]()
    var redCards = [Card]()
    var greenCards = [Card]()
    var yellowCards = [Card]()
    var wizardCards = [Card]()
    
    let position : Int
    
    var allCardsMinusPlayedCards = DeckOfCards().shuffledCards
    
    var cardsThatShouldWinTheTrick = [Card]()
    
    // id: 0 < id < 10 for human players, id > 10 for computer players
    var id : Int
    
    var score : Int = 0
    
    var tricksPlanned : Int = 0
    var tricksWon : Int = 0
    
    init(thisName: String, thisLevel : String, thisID: Int, thisPosition : Int?) {
        name = thisName
        level = thisLevel
        id = thisID

        if let prefColorSorting = defaults.array(forKey: "colorSorting") as? [String]{
            colorSorting = prefColorSorting
        }
        
        if let prefSortingOrderAscending = defaults.bool(forKey: "sortingOrder") as? Bool{
            sortingOrderAscending = prefSortingOrderAscending
        }
        
        if thisPosition != nil {
            position = thisPosition!
            print("\(name), position: \(position)")
        }
        else {
            position = 0
        }
    }
    
    convenience init (thisName : String, makeHuman : Bool) {
        self.init(thisName: thisName, thisLevel: "generic", thisID: 0, thisPosition: 0)
        isHuman = makeHuman
        if !isHuman {
             id = Int.random(in: 1...999999)
        }
    }
    
    // MARK: - utility functions
    func sortCards() {
        if sortingOrderAscending {
            cards = cards.sorted { (a, b) -> Bool in

                let aColor : Int = colorSorting.firstIndex(of: a.color)!
                let bColor : Int = colorSorting.firstIndex(of: b.color)!

                if ((aColor)*13)+a.value > ((bColor)*13)+b.value {
                    return true
                }
                else {
                    return false
                }
            }
        }
        else {
            cards = cards.sorted { (a, b) -> Bool in
                let aColor : Int = colorSorting.firstIndex(of: a.color)!
                let bColor : Int = colorSorting.firstIndex(of: b.color)!
                
                if ((aColor)*13)+a.value < ((bColor)*13)+b.value {
                    return true
                }
                else {
                    return false
                }
            }
        }

    }
    
    // sort the cards right before the card needs to be played. Index 0 should be the best card to play. Need to know the trump and cards ahve been played.
    func sortCardsToPlay(thisTrump : String, cardsPlayed : [Card]) {
        print("- - player[\(name)].sortCardsToPlay")
        
        var cardsPlayedArray = cardsPlayed
        var suit = ""

        // clear the playable cards
        playableCards.removeAll()
        for thisCard in cards {
            thisCard.canBePlayed = false
        }
        
        // only if there are cards played
        if cardsPlayedArray.count > 0 {
            var winningCard = cardsPlayedArray.removeFirst()
            
            // find suit
            if winningCard.color == "Black" {
                for thisCard in cardsPlayedArray {
                    if thisCard.color != "Black" {
                        suit = thisCard.color
                    }
                }
            }
            else {
                suit = winningCard.color
            }
            
            if suit == "" {
                playableCards.append(contentsOf: cards)
                
            }
            else {
                playableCards.append(contentsOf: cards.filter{$0.color == suit})
                
                if playableCards.count == 0 {
                    playableCards.append(contentsOf: cards)
                }
                else {
                    playableCards.append(contentsOf: cards.filter{$0.color == "Black"})
                }
            }
            calcSpecificProbability(suit: suit, winningCard: winningCard)
        }
        else {
            playableCards.append(contentsOf: cards)
        }
        
        for thisCard in playableCards {
            thisCard.canBePlayed = true
        }
        
        
    }
    
    // method called to play a card
    func playCard(thisTrump : String, theseCards : [Card]) -> Card {
        
        print("\(name).playCard()")

        // if card array is empty:
        // else if card array see, if you have the color || if you have a 14
        // decide how many tricks are possible vs tricksPlanned - tricksWon
        // play card = return the card and take it out of both
        
        sortCardsToPlay(thisTrump: thisTrump, cardsPlayed: theseCards)
        

        let cardToPlay = playableCards.randomElement()
        print("player[\(name)].playCard(\(cardToPlay!.id))")
        cardToPlay!.playedByPlayer = id
        
        cards = cards.filter{$0 !== cardToPlay}
        
        return cardToPlay!
        
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
                if thisCard.color != "Black" {
                    suite = thisCard.color
                    break
                }
            }
            
            for thisCard in playedCards {
                if thisCard.color != suite {
                    if thisCard.color == "Black" {
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
            if thisCard.value == 100 {
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
    
    func calcGenProbForAllCards() {
        removeCardsInTrickFromInternalDeck()

        for thisCard in cards {
            thisCard.genProbability = probabilityForCard(thisCard: thisCard)
        }
        print("genprob calculated")
    }
    
    func probabilityForCard(thisCard : Card) -> Float{
        let thisTrump = delegate?.trump
        let sameColorHigherValue : Float = Float(allCardsMinusPlayedCards.filter{$0.color == thisCard.color && $0.value > thisCard.value}.count - cards.filter{$0.color == thisCard.color && $0.value > thisCard.value}.count)
        let remainingColorCard = Float(allCardsMinusPlayedCards.filter{$0.color == thisCard.color}.count + cards.filter{$0.color == thisCard.color}.count)
        let trumpCards : Float = Float(allCardsMinusPlayedCards.filter{$0.color == thisTrump}.count - cards.filter{$0.color == thisTrump}.count)
        let higherTrumpCards : Float = Float(allCardsMinusPlayedCards.filter{$0.color == thisTrump && $0.value > thisCard.value}.count - cards.filter{$0.color == thisTrump && $0.value > thisCard.value}.count)
        let starCards : Float = Float(allCardsMinusPlayedCards.filter{$0.value == 100}.count - cards.filter{$0.value == 100}.count)
        let cardsLeftToPlay : Float = Float(allCardsMinusPlayedCards.count - cards.count)
        let probabilityForPlayerToHaveColorCard = 1 - (remainingColorCard/cardsLeftToPlay - Float(cards.filter{$0.color == thisCard.color}.count))
        
        var probability : Float = 0
        
        if thisCard.value == 0 {
            thisCard.genProbability = 0
        }
        else if thisCard.color != thisTrump {
            probability = 1 - ((trumpCards * probabilityForPlayerToHaveColorCard + sameColorHigherValue + starCards)/cardsLeftToPlay)
        }
        else if thisCard.value == 100 {
            probability = Float(1 - (starCards/cardsLeftToPlay))
        }
            // TODO: angleichung formel
        else if thisCard.color == thisTrump {
            probability = Float(1 - ((higherTrumpCards + starCards)/cardsLeftToPlay))
        }
        return probability
    }
    
    func calcSpecificProbability(suit: String, winningCard: Card) {
        
        if winningCard.value == 100 {
            for thisCard in playableCards {
                thisCard.specificProbability = 0
            }
        }
        else {
            for thisCard in playableCards {
                
                // playing a wizard
                if thisCard.value == 100 {
                    print("case0")
                    thisCard.specificProbability = 1
                    continue
                }
                    // playing a card not the color of the suit or trump
                else if (thisCard.color != suit && thisCard.color != delegate?.trump && thisCard.color != "Black" && winningCard.value != 0) {
                    thisCard.specificProbability = 0
                    print("case1")
                }
                    // this card is trump and the winningCard is not
                else if thisCard.color == (delegate?.trump)! && winningCard.color != (delegate?.trump)! {
                    thisCard.specificProbability = probabilityForCard(thisCard: thisCard) / Float((delegate?.playersInOrderOfTrick.count)!)
                    print("case2")
                }
                    // only suit cards played
                else if (thisCard.color == suit && thisCard.value < winningCard.value && winningCard.color == suit) {
                    thisCard.specificProbability = 0
                    print("case3")
                }
                    // zero card
                else if thisCard.value == 0 {
                    thisCard.specificProbability = 0
                    print("case4")
                }
                    // playing a trump among suit cards
                else if winningCard.color == suit && thisCard.color == delegate?.trump {
                    thisCard.specificProbability = probabilityForCard(thisCard: thisCard)
                    print("case5")
                    // TODO: see if the players left have the suit color or if there are even any suit cards left
                }
                else if winningCard.value == 0 && thisCard.value != 0 {
                    if (delegate?.playersInOrderOfTrick.count)! == 1 {
                        thisCard.specificProbability = 1
                    } else {
                        thisCard.specificProbability = probabilityForCard(thisCard: thisCard) / Float((delegate?.playersInOrderOfTrick.count)!)
                    }
                    print("case6")
                }
                
                else if thisCard.color == winningCard.color && thisCard.value > winningCard.value {
                    thisCard.specificProbability = probabilityForCard(thisCard: thisCard) / Float((delegate?.playersInOrderOfTrick.count)!)
                    print("case7")
                }
            }
        }
    
        for thisCard in playableCards {
            print("##### specProb: \(thisCard.id) = \(thisCard.specificProbability), genProb: \(thisCard.genProbability)")
        }
    }
    
    func calculateBestTrumpColor() -> String {
        var trumpColor = ""
        
        var allCardsInArrays = [[Card]]()
        
        for thisColor in colorSorting {
            if thisColor.lowercased() != "black" {
                let theseCards = cards.filter{$0.color == thisColor}
                allCardsInArrays.append(theseCards)
                
            }
        }
        allCardsInArrays.sort { (x, y) -> Bool in
            if x.count > y.count {
                return true
            }
            else {
                return false
            }
        }
        var highestQuantifier = 0
        var hightestQantifierColor = ""
        
        for thisColoredCards in allCardsInArrays {
            let thisQ = thisColoredCards.reduce(0, { x, y in x + y.value })
            if thisQ > highestQuantifier {
                highestQuantifier = thisQ
                hightestQantifierColor = (thisColoredCards.first?.color)!
            }
        }
        
        if allCardsInArrays.first?.first?.color == hightestQantifierColor {
            trumpColor = hightestQantifierColor
        }  
        return trumpColor
    }
    
    func removeCardsInTrickFromInternalDeck(){
        if let playedCards = delegate?.cardsInTrick {
            for thisCard in playedCards {
                allCardsMinusPlayedCards = allCardsMinusPlayedCards.filter{$0.id != thisCard.id}
            }
        }
    }
}
