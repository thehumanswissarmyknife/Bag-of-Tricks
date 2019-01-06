//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    let CARDWIDTHINPLAYAREA =  140
    let CARDHEIGHTINPLAYAREA = 220
    
    let CARDHEIGHTINHUMANAREA = 220
    let CARDWIDTHINHUMANAREA = 140
    
    // MARK: OUTLETS FOR THE UI
    @IBOutlet var vRootView: UIView!
    @IBOutlet weak var vParkingLot: UIView!
    @IBOutlet weak var ivTrumpCard: UIImageView!
    @IBOutlet weak var vNextTrick: UIButton!
    
    // MARK: - LABELS FOR THE PLAYER AND HOW MANY TRICKS THEY WON IN THIS ROUND
    // labels for the players
    @IBOutlet weak var labelTricksPlayed: UILabel!
    
    @IBOutlet weak var labelPlayerYou: UILabel!
    @IBOutlet weak var labelPlayerOne: UILabel!
    @IBOutlet weak var labelPlayerTwo: UILabel!
    @IBOutlet weak var labelPlayerThree: UILabel!
    @IBOutlet weak var labelPlayerFour: UILabel!
    
    var playerLabels = [UILabel]()
    @IBOutlet weak var vCardView: UIView!
    @IBOutlet weak var vCardsInTrick: UIView!
    
    // MARK: - VARIABLES FOR THE GAME LOGIC
    // TODO: Userdefaults integration für name, anzahl player...
    var defaults = UserDefaults.standard
    
    var roundsInTotal : Int = 0
    var currentRoundNumber : Int = 1    // correspondts to the number of cards dealt
    var tricksPlayedInRound : Int = 0      // how many of the tricks of the round have been played
    
    var players = [Player]()        // array holding the players. 0 is always the human in front of the device
    var playersInOrderOfTrick = [Player]() // this array gets shifted after each round
    var winningCard : Card?
    var winningPlayer : Player?
    var trump : String = ""         // string with the trump color for the round
    var floppedTrumpCard : Card?    // the flopped card determining the trump
    var cardDeck = DeckOfCards()    // the card deck
    var cardsInTrick = [Card]()

    var myName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        playerLabels = [labelPlayerYou, labelPlayerOne, labelPlayerTwo, labelPlayerThree, labelPlayerFour]
        
        for thisLabel in playerLabels {
            thisLabel.isHidden = true
            thisLabel.textColor = UIColor.black
        }
        
        
        if let name = defaults.string(forKey: "UserName") as? String {
            myName = name
            print("found the name")
        }
        
        // TODO: create alert style window for input
        
        startGame()
    }
    

    
    // MARK: - GAME FUNCTIONS
    func startGame() {
        defaults.set("Luigi", forKey: "UserName")
        print(".startGame")
        // TODO: init all variables
        
        // create players
        // human player has id 0
        players.append(Player(thisName: myName, makeHuman: true))
        createPlayers(n: 2)
        
        // add all players to the players in order array
        playersInOrderOfTrick = players
        
        // how many tricks - can be calculated byy
        roundsInTotal = cardDeck.shuffledCards.count / players.count
        
        // start the round
        startRound()
    }
    

    func startRound(){
        
        print("starting new nound")
        
        cardDeck = DeckOfCards()
        clearCardsInTrick()
        dealCards(howManyCards: currentRoundNumber)
        
        for thisPlayer in playersInOrderOfTrick {
            thisPlayer.tricksWon = 0
            let tricksEstimated = thisPlayer.calculateTricksToWin(thisTrump: trump)
        }
        
        updateTricksUI()
        newPlay()
    }
    
    func newPlay(){
        print("newPlay")
        clearCardsInTrick()

        // this loop will go on till the number of tricks played is equal to the tricks in the round
        while tricksPlayedInRound < currentRoundNumber && playersInOrderOfTrick.count > 0 {
            // continuing playing the trick:
            // let the next player play his card
            
            if !playersInOrderOfTrick[0].isHuman && playersInOrderOfTrick[0].cards.count > 0{
                cardsInTrick.append(playersInOrderOfTrick[0].playCard(thisTrump: trump, theseCards: cardsInTrick))
                displayCardsInTrick()
                playersInOrderOfTrick.removeFirst()
            }
            else {
                // human player! break from the loop
                // TODO: disply that the player should play a card
                break
            }
        }

        // if all cards have been played
        if playersInOrderOfTrick.count == 0 {
            // evaluate trick -> sets winningCard and winningPlayer
            evaluate(cardsInTrick: cardsInTrick)
            
            // fill up the playersInOrderOfTrick array and shift it accordingly
            playersInOrderOfTrick = players
            shiftPlayers(thisWinningPlayer: winningPlayer!)
            
            // increase the numberOfTricksPlayed
            tricksPlayedInRound += 1
            vNextTrick.isHidden = false
            cardsInTrick.removeAll()
        }
        
        // if all tricks of the round have been played
        if tricksPlayedInRound == currentRoundNumber {
            // evaluate this round
            for thisPlayer in players {
                let oldScore = thisPlayer.score
                if thisPlayer.tricksPlanned == thisPlayer.tricksWon {
                    // update the scores of all players
                    thisPlayer.score += 20 + (thisPlayer.tricksWon * 10)
                }
                else {
                    thisPlayer.score -= abs(thisPlayer.tricksPlanned - thisPlayer.tricksWon) * 10
                }
                
                print("\(thisPlayer.name): \(thisPlayer.tricksWon)/\(thisPlayer.tricksPlanned), old score: \(oldScore), new score: \(thisPlayer.score)")
                // set tricksPlanned & trickedWon to zero for all players
                thisPlayer.tricksWon = 0
                thisPlayer.tricksPlanned = 0
            }
            // increase currentNumberOftricks
            currentRoundNumber += 1
            
            // set tricksplayed to 0
            tricksPlayedInRound = 0
            
            // start the next round: deal cards, have the players bet....
            vNextTrick.isHidden = false
        }
    }
    
    // function that takes the number of cards per player to be dealt, then deals the cards to the players and also turns the flop card.
    func dealCards(howManyCards : Int) {
        print("dealCards")
        
        // first empty all players cards arrays
        for thisPlayer in players {
            thisPlayer.cards.removeAll()
        }
        
        for _ in 1...howManyCards {
            for thisPlayer in players {
                let thisCard = self.cardDeck.dealCard()
                thisCard.playedByPlayer = thisPlayer.id
                thisPlayer.cards.append(thisCard)
                
                // TODO: to make it less akward, make the human cards appear slowly
                if thisPlayer.isHuman {
                    self.displayPlayerCards()
                }
            }
        }
        
        // check if there are cards left
        if cardDeck.shuffledCards.count > 0 {
            floppedTrumpCard = cardDeck.dealCard()
            trump = (floppedTrumpCard?.color)!
            displayTrumpCard()
        }
        else{
            // no trump
            trump = ""
        }
        printPlayersCards()
    }

    // evaluate the trick
    func evaluate(cardsInTrick : [Card]) {
        print("trick[\(tricksPlayedInRound), trump:\(trump)].evaluate")
        
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
            winningPlayer?.tricksWon += 1
            printWinners()
            updateTricksUI()
//            displayWinner()
        }
    }

    // MARK: - UI UPDATING FUNCTIONS
    
    // displays the cards of the human player in the card array.
    // each card is a button
    func displayPlayerCards(){
        print("displayPlayerCards")
        // human player is always the first in the players array
        let theseCards = players[0].cards
        
        for thisCardView in vCardView.subviews {
            thisCardView.removeFromSuperview()
        }
        
        let widthOfCards = CARDWIDTHINPLAYAREA + (theseCards.count * 40)
        let widthOfView = vCardView.frame.width - 40
        var initialOffset : Int = ((Int(widthOfView) - widthOfCards) / 2)
        let addedPixel = 40
        
        for n in 0..<theseCards.count {
            let thisCard = players[0].cards[n]
            print("cfreate button \(thisCard.id)")
            let btnCard = UIButton()
            btnCard.setImage(UIImage(named: thisCard.id), for: .normal)
            btnCard.frame = CGRect(x: initialOffset, y: 10, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
            btnCard.setTitle("\(thisCard.id)", for: .normal)
            btnCard.tag = 100 + n
            btnCard.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
            vCardView.addSubview(btnCard)
            
            initialOffset += addedPixel
        }
    }

    // display the cards in the current trick
    func displayCardsInTrick(){
        print("displayCardsInTrick")
        clearCardsInTrick()
        var offset = 0
        for thisCard in cardsInTrick {
            let vCardPlusName = UIView()
            let ivCard = UIImageView(image: UIImage(named: thisCard.id))
            let labelName = UILabel()
            
            labelName.text = players.filter{$0.id == thisCard.playedByPlayer}[0].name
            labelName.font = UIFont.init(name: "Futura", size: 20)
            labelName.textColor = UIColor.black
            labelName.textAlignment = NSTextAlignment.center
            
            ivCard.frame = CGRect(x: offset, y: 0, width: CARDWIDTHINPLAYAREA, height: CARDHEIGHTINPLAYAREA)
            labelName.frame = CGRect(x: offset, y: CARDHEIGHTINPLAYAREA + 20, width: CARDWIDTHINPLAYAREA, height: 30)
            
            vCardPlusName.addSubview(ivCard)
            vCardPlusName.addSubview(labelName)
            vCardsInTrick.addSubview(vCardPlusName)
            offset += CARDWIDTHINPLAYAREA + 20
        }
    }
    
    // display the trump card
    func displayTrumpCard(){
        print("displayTrumpCard")
        ivTrumpCard.image = UIImage(named: floppedTrumpCard!.id)
    }
    
    
    // updates how many tricks each player has won vs planned
    func updateTricksUI(){
        print("updateTricksUI")
        for n in 0..<players.count {
            playerLabels[n].text = "\(players[n].name): \(players[n].tricksWon)/\(players[n].tricksPlanned)"
            playerLabels[n].isHidden = false
        }
    }
    
    func displayWinner(){
        
        for n in 0..<cardsInTrick.count {
            if cardsInTrick[n] === winningCard {
                let label = vCardsInTrick.subviews[n].subviews[1] as! UILabel
                label.textColor = UIColor.blue
            }
        }
    }
    
    // removes all cards in the trick area from the view
    func clearCardsInTrick(){
        print("clearCardsInTrick")
        // clear all images from the view
        for cardView in vCardsInTrick.subviews {
            cardView.removeFromSuperview()
        }
    }
    
    // MARK: - PRINTING FUNCTIONS
    // print the order of the players!
    func printPlayerOrder(){
        // perfunctory printing
        var playerOrder = ""
        for thisPlayer in playersInOrderOfTrick {
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
    
    // prints the cards of all players to the console
    func printPlayersCards(){
        for thisPlayer in players {
            var cards = "\(thisPlayer.name):"
            for thisCard in thisPlayer.cards {
                cards = "\(cards) \(thisCard.id)"
            }
            print(cards)
        }
    }
    
    func printWinners(){
        print("-------------------------------------")
        print("trick.winningCard: \(winningCard!.id)")
        print("trick.winningPlayer: \(winningPlayer!.name)")
        print("=====================================")
    }
    
    
    // MARK: - UTILITY FUNCTIONS
    @IBAction func btnNextTrick(_ sender: UIButton) {
        print("btnNextTrick")
        vNextTrick.isHidden = true
        // check if we have to play the next trick or start a new round (dealing cards, etc.)
        if tricksPlayedInRound == 0 {
            startRound()
        }
        else {
            newPlay()
        }
    }
    // function that is triggered, when a card is selected
    @objc func pressed(sender: UIButton){
        print("pressedCard")
        let index = sender.tag - 100       // the cards start with the tag 100
        let cardId = sender.title(for: .normal)
        
        cardsInTrick.append(playersInOrderOfTrick[0].playThisCard(thisCardID: cardId!))
        displayCardsInTrick()
        displayPlayerCards()
        playersInOrderOfTrick.removeFirst()
        
        newPlay()
        
    }
    
    // shifts the array playersInOrderOfTrick
    func shiftPlayers(thisWinningPlayer : Player) {
        print("shiftPlayers")
        for _ in 0..<playersInOrderOfTrick.count {
            if thisWinningPlayer !== playersInOrderOfTrick[0] {
                playersInOrderOfTrick.append(playersInOrderOfTrick.removeFirst())
            }
            else {
                break
            }
        }
        printPlayerOrder()
    }
    
    // creates a number of players with names taken at random from an array
    func createPlayers (n : Int) {
        print("createPlayers")
        // some names, that are picked at random
        var playerNames = ["Peter", "Louise", "Claudia", "Roberto", "Michael", "Celine", "Paula", "Elvira", "Daniel", "Francesca"]
        for _ in 1...n {
            let random = Int.random(in: 0..<playerNames.count)
            let aPlayer = Player(thisName: playerNames.remove(at: random), thisLevel: "easy", thisID: random+1)
            players.append(aPlayer)
        }
    }
    

}
