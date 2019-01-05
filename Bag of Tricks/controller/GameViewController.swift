//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: OUTLETS FOR THE UI
    @IBOutlet var vRootView: UIView!
    @IBOutlet weak var vParkingLot: UIView!
    @IBOutlet weak var ivTrumpCard: UIImageView!
    @IBOutlet weak var vNextTrick: UIButton!
    
    // MARK: - IMAGEVIEWS FOR THE CARDS OF EACH TRICK
    // image for the dealerCard
    @IBOutlet weak var ivDealerCardPlayerFour: UIImageView!
    @IBOutlet weak var ivDealerCardPlayerThree: UIImageView!
    @IBOutlet weak var ivDealerCardPlayerTwo: UIImageView!
    @IBOutlet weak var ivDealerCardPlayerOne: UIImageView!
    @IBOutlet weak var ivDealerCardPlayerYou: UIImageView!
    
    // MARK: - LABELS FOR THE PLAYER AND HOW MANY TRICKS THEY WON IN THIS ROUND
    // labels for the players
    @IBOutlet weak var labelTricksPlayed: UILabel!
    
    @IBOutlet weak var labelPlayerYou: UILabel!
    @IBOutlet weak var labelPlayerOne: UILabel!
    @IBOutlet weak var labelPlayerTwo: UILabel!
    @IBOutlet weak var labelPlayerThree: UILabel!
    @IBOutlet weak var labelPlayerFour: UILabel!
    
    var playerLabels = [UILabel]()
    
    // MARK: - Modalview
    // TODO: ALERT
    @IBOutlet weak var vModalView: UIView!
    @IBOutlet weak var btnPlayGame: UIButton!
    
    // modaler View für die bestimmung der Spieleranzahl
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var vCardView: UIView!
    @IBOutlet weak var vCardsInTrick: UIView!
    
    // MARK: - VARIABLES FOR THE GAME LOGIC
    // TODO: Userdefaults integration für name, anzahl player...
    var defaults = UserDefaults.standard
    
    var roundsInTotal : Int = 0
    var currentNumberOfTricks : Int = 1    // correspondts to the number of cards dealt
    var tricksPlayed : Int = 0      // how many of the tricks of the round have been played
    
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
        }
        
        
        if let name = defaults.string(forKey: "UserName") as? String {
            myName = name
            print("found the name")
        }
        
//        vModalView.isHidden = false
//        vRootView.addSubview(vModalView)
        
        // TODO: create alert style window for input
        
        /* TODO: refactor all functionality to the gameController:
         this way it's easier to trigger the play-input and hae all variables at hand
         
         -> bagOfTricks
         -> playerArray
         -> each trick
         -> all loops through the rounds are in the main game controller
         */
        
        startGame()


        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - GAME FUNCTIONS
    func startGame() {
        defaults.set("Luigi", forKey: "UserName")
        print(".startGame")
        // TODO: init all variables
        
        // create players
        // human player has id 0
        players.append(Player(thisName: myName, thisLevel: "easy", thisID: 0))
        players[0].isHuman = true
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
        dealCards(howManyCards: currentNumberOfTricks)
        displayPlayerCards(theseCards: players[0].cards)
        let trumpId = floppedTrumpCard?.id as! String
        ivTrumpCard.image = UIImage(named: trumpId)
        
        for thisPlayer in playersInOrderOfTrick {
            thisPlayer.tricksWon = 0
            let tricksEstimated = thisPlayer.calculateTricksToWin(thisTrump: trump)
        }
        
        updateTricksUI()
        newPlay()
    }
    
    func newPlay(){
        
        clearCardsInTrick()
        

        
        // this loop will go on till the number of tricks played is equal to the tricks in the round
        while tricksPlayed < currentNumberOfTricks && playersInOrderOfTrick.count > 0 {
            // continuing playing the trick:
            // let the next player play his card
            
            if !playersInOrderOfTrick[0].isHuman && playersInOrderOfTrick[0].cards.count > 0{
                cardsInTrick.append(playersInOrderOfTrick[0].playCard(thisTrump: trump, theseCards: cardsInTrick))
                displayCardsInTrick()
                playersInOrderOfTrick.removeFirst()
            }
            else {
                // human player!
                // break from the loop
                // disply that the player should play a card
                // when the player has played his card, the
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
            tricksPlayed += 1
            vNextTrick.isHidden = false
            cardsInTrick.removeAll()
        }
        
        // if all tricks of the round have been played
        if tricksPlayed == currentNumberOfTricks {
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
            currentNumberOfTricks += 1
            
            // set tricksplayed to 0
            tricksPlayed = 0
            
            // start the next round: deal cards, have the players bet....
            vNextTrick.isHidden = false
            
        }
        
 
    }
    
    
    // function that takes the number of cards per player to be dealt, then deals the cards to the players and also turns the flop card.
    func dealCards(howManyCards : Int) {
        print("bagOfTricks.dealCards")
        
        // first empty all players cards arrays
        for thisPlayer in players {
            thisPlayer.cards.removeAll()
        }
        
        for _ in 1...howManyCards {
            for thisPlayer in players {
                let thisCard = cardDeck.dealCard()
                thisCard.playedByPlayer = thisPlayer.id
                thisPlayer.cards.append(thisCard)
            }
        }
        
        // check if there are cards left
        if cardDeck.shuffledCards.count > 0 {
            floppedTrumpCard = cardDeck.dealCard()
            trump = (floppedTrumpCard?.color)!
        }
        else{
            // no trump
            trump = ""
        }
        
//        tricksPlayed += 1
        
        // print the delat cards to the console
        printPlayersCards()
//        print("cards remaining: \(cardDeck.shuffledCards.count)")
//        print("cards played: \(cardDeck.playedCards.count)")
        
        
        
    }
    
    // creates a number of players with names taken at random from an array
    func createPlayers (n : Int) {
        // some names, that are picked at random
        var playerNames = ["Peter", "Louise", "Claudia", "Roberto", "Michael", "Celine", "Paula", "Elvira", "Daniel", "Francesca"]
        for _ in 1...n {
            let random = Int.random(in: 0..<playerNames.count)
            let aPlayer = Player(thisName: playerNames.remove(at: random), thisLevel: "easy", thisID: random+1)
            players.append(aPlayer)
        }
    }
    
    // evaluate the trick
    func evaluate(cardsInTrick : [Card]) {
        print("trick[\(tricksPlayed), trump:\(trump)].evaluate")
        
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
            updateTricksUI()
            print("-------------------------------------")
            print("trick.winningCard: \(winningCard!.id)")
            print("trick.winningPlayer: \(winningPlayer!.name)")
            print("=====================================")
        }
    }
    
    // MARK: - Functions for the player
    
    // displays the cards of the human player in the card array.
    // each card is a button
    func displayPlayerCards(theseCards : [Card]){
        
        for thisCardView in vCardView.subviews {
            thisCardView.removeFromSuperview()
        }
        
        
        let widthOfCards = 120 + (theseCards.count * 40)
        let widthOfView = vCardView.frame.width - 40
        var initialOffset : Int = ((Int(widthOfView) - widthOfCards) / 2)
        let addedPixel = 40
        
        for n in 0..<theseCards.count {
            let thisCard = players[0].cards[n]
            print("cfreate button \(thisCard.id)")
            let btnCard = UIButton()
            btnCard.setImage(UIImage(named: thisCard.id), for: .normal)
            btnCard.frame = CGRect(x: initialOffset, y: 10, width: 140, height: 220)
            btnCard.setTitle("\(thisCard.id)", for: .normal)
            btnCard.tag = 100 + n
            btnCard.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
            vCardView.addSubview(btnCard)
            
            initialOffset += addedPixel
        }
    }
    
    func clearCardsInTrick(){
        // clear all images from the view
        for cardView in vCardsInTrick.subviews {
            cardView.removeFromSuperview()
        }
    }
    
    func displayCardsInTrick(){
        
        clearCardsInTrick()
        
        var offset = 0
        for thisCard in cardsInTrick {
            let iCard = UIImage(named: thisCard.id)
            let ivCard = UIImageView(image: iCard)
            ivCard.frame = CGRect(x: offset, y: 0, width: 140, height: 220)
            vCardsInTrick.addSubview(ivCard)
            offset += 40
        }
    }
    
    // MARK: - UTILITY FUNCTIONS
    // functions triggered, when the "PLAY GAME" button is pressed in the modal view
    @IBAction func btnPlayGamePressed(_ sender: UIButton) {
        myName = tfName.text!
        labelPlayerYou.text = "\(myName): -/15"
        defaults.set(myName, forKey:"playerName")
        vModalView.isHidden = true
        vParkingLot.addSubview(vModalView)
    }
    
    @IBAction func btnNextTrick(_ sender: UIButton) {
        vNextTrick.isHidden = true
        // check if we have to play the next trick or start a new round (dealing cards, etc.)
        if tricksPlayed == 0 {
            startRound()
        }
        else {
            newPlay()
        }
    }
    // function that is triggered, when a card is selected
    @objc func pressed(sender: UIButton){
        let index = sender.tag - 100       // the cards start with the tag 100
        let cardId = sender.title(for: .normal)
        
        cardsInTrick.append(playersInOrderOfTrick[0].playThisCard(thisCardID: cardId!))
        displayCardsInTrick()
        displayPlayerCards(theseCards: playersInOrderOfTrick[0].cards)
        playersInOrderOfTrick.removeFirst()
        
        newPlay()
        
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
    
    // shifts the array playersInOrderOfTrick
    func shiftPlayers(thisWinningPlayer : Player) {
       
        for _ in 0..<playersInOrderOfTrick.count {
            if thisWinningPlayer !== playersInOrderOfTrick[0] {
                playersInOrderOfTrick.append(playersInOrderOfTrick.removeFirst())
            }
            else {
                break
            }
        }
        
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
    
    func updateTricksUI(){
        for n in 0..<players.count {
            playerLabels[n].text = "\(players[n].name): \(players[n].tricksWon)/\(players[n].tricksPlanned)"
            playerLabels[n].isHidden = false
        }
    }
    
    //    // plays a round : starting with dealing 1 card, playing the trick, dealing two cards, ...
    //    func playBag() {
    //        print(".playBag")
    //
    //        for thisManyTricksInRound in 1...roundsInTotal {
    //
    //            print("")
    //            print("bagOfTricks.playBag: \(thisManyTricksInRound)/\(roundsInTotal)")
    //            print("-------------------------")
    //
    //            cardDeck = DeckOfCards()
    //            // deal cards
    //            dealCards(howManyCards: thisManyTricksInRound)
    //
    //            // the tricks inside each round!
    //            for currentTrick in 1...thisManyTricksInRound {
    //                // create a trick
    //                let thisTrick = Trick(thisTrump: trump, thesePlayers: playersInOrderOfTrick)
    //
    //                // play the trick and assign the winner to a variable
    //                print("### trick(\(currentTrick)) ###")
    //
    //                for thisPlayer in playersInOrderOfTrick {
    //                    if thisPlayer.isHuman {
    //
    //                    }
    //                    else {
    //                        let cardPlayed = thisPlayer.playCard(thisTrump: trump, theseCards: thisTrick.cardsInTrick)
    //                        thisTrick.cardsInTrick.append(cardPlayed)
    //                    }
    //                }
    //
    //                let thisWinningPlayer = thisTrick.play()
    //
    //                // shift the players array
    //                shiftPlayers(thisWinningPlayer: thisWinningPlayer)
    //
    //                // update tricksWon of the winner
    //                thisWinningPlayer.tricksWon += 1
    //
    //                // TODO: update the opponents of all players
    //                for thisPlayer in players {
    //                    thisPlayer.updateOppponents(playedCards: thisTrick.cardsInTrick)
    //                }
    //            }
    //        }
    //    }

}
