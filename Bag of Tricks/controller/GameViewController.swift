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
    @IBOutlet weak var vCardView: UIView!
    @IBOutlet weak var vCardsInTrick: UIView!
    
    
    // MARK: - LABELS FOR THE PLAYER AND HOW MANY TRICKS THEY WON IN THIS ROUND
    // labels for the players
    @IBOutlet weak var labelTricksPlayed: UILabel!
    @IBOutlet weak var labelWinner: UILabel!
    
    @IBOutlet weak var labelPlayerYou: UILabel!
    @IBOutlet weak var labelPlayerOne: UILabel!
    @IBOutlet weak var labelPlayerTwo: UILabel!
    @IBOutlet weak var labelPlayerThree: UILabel!
    @IBOutlet weak var labelPlayerFour: UILabel!
    
    var playerLabels = [UILabel]()

    
    // MARK: - VARIABLES FOR THE GAME LOGIC
    // TODO: Userdefaults integration für name, anzahl player...
    var defaults = UserDefaults.standard
    
    var roundsInTotal : Int = 0
    var currentRoundNumber : Int = 1    // correspondts to the number of cards dealt
    var tricksPlayedInRound : Int = 0      // how many of the tricks of the round have been played
    
    var players = [Player]()        // array holding the players. 0 is always the human in front of the device
    var playersInOrderOfTrick = [Player]() // this array gets shifted after each round
    var winningCard : Card = Card(thisColor: "blurp", thisValue: -1)
    var winningPlayer : Player = Player(thisName: "hansens", makeHuman: false)
    var trump : String = ""         // string with the trump color for the round
    var floppedTrumpCard : Card?    // the flopped card determining the trump
    var cardDeck = DeckOfCards()    // the card deck
    var cardsInTrick = [Card]()
    
    var playerIndexWhoStartsTheRound = 0

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
        print("\(players[playerIndexWhoStartsTheRound].name) is first to play")
        
        cardDeck = DeckOfCards()
        clearCardsInTrick()
        dealCards(howManyCards: currentRoundNumber)
        
        // shift the players so that the one who is supposed to start, is at index 0
        shiftPlayers(thisWinningPlayer: players[playerIndexWhoStartsTheRound])
        
        // if the flopped card is a wizard, the first player has to choose the trump color
        if floppedTrumpCard!.value == 14 {
            if !playersInOrderOfTrick[0].isHuman{
                // for the moment pick a random color
                let colors = ["blue", "green", "red", "yellow"]
                floppedTrumpCard = Card(thisColor: colors[Int.random(in: 0...3)], thisValue: 15)
                trump = (floppedTrumpCard?.color)!
                displayTrumpCard()
            }
        }
        
        for thisPlayer in playersInOrderOfTrick {
            thisPlayer.tricksWon = 0
            if thisPlayer.isHuman == false {
                let tricksEstimated = thisPlayer.calculateTricksToWin(thisTrump: trump)
            }
            else {
                displayTrickBettingScreen()
            }
        }
        
        updateTricksUI()
    }
    
    func newPlay(){
        print("newPlay")
        clearCardsInTrick()
        labelWinner.isHidden = true

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
//            evaluate(cardsInTrick: cardsInTrick)
            evaluateCardsInTrick()
            
            // fill up the playersInOrderOfTrick array and shift it accordingly
            playersInOrderOfTrick = players
            shiftPlayers(thisWinningPlayer: winningPlayer)
            
            // increase the numberOfTricksPlayed
            tricksPlayedInRound += 1
            
            if tricksPlayedInRound < currentRoundNumber {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.btnNextTrick(self.vNextTrick)
                }
            }
            else {
                // show the new scores!
//                displayScores()
                
            }
            
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
            
            playerIndexWhoStartsTheRound += 1
            if playerIndexWhoStartsTheRound >= players.count {
                playerIndexWhoStartsTheRound -= players.count
            }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.displayPlayerCards()
                    }
                    
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
            trump = "none"
        }
        printPlayersCards()
    }

    
    // evaluate the cards in this trick
    func evaluateCardsInTrick(){
        print("evaluateCardsInTrick")
        // let's assunme that the first card is the winner and remove it from the array
        winningCard = cardsInTrick.removeFirst()
        
        for thisCard in cardsInTrick {
            if winningCard.value == 14 {
                // Wizarsd always win
                break
            }
            
            if thisCard.value == 14 {
                winningCard = thisCard
                break
            }
            
            if thisCard.value != 0 {
                // if the current card is not nil
                if thisCard.color == trump && thisCard.color != winningCard.color {
                    winningCard = thisCard
                }
                
                if thisCard.color == winningCard.color && thisCard.value > winningCard.value {
                    winningCard = thisCard
                }
                
                if winningCard.value == 0 && thisCard.value > 0 {
                    winningCard = thisCard
                }
            }
        }
        
        winningPlayer = players.filter{$0.id == winningCard.playedByPlayer}[0]
        winningPlayer.tricksWon += 1
        labelWinner.text = "\(winningPlayer.name) won"
        labelWinner.isHidden = false
        printWinners()
        updateTricksUI()
    }

    // MARK: - UI UPDATING FUNCTIONS
    
    // displays the cards of the human player in the card array.
    // each card is a button
    func displayPlayerCards(){
        print("displayPlayerCards")
        // human player is always the first in the players array
        var theseCards = players[0].cards
        
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
            btnCard.isEnabled = thisCard.canBePlayed
            btnCard.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
            vCardView.addSubview(btnCard)
            
            initialOffset += addedPixel
        }
    }
    
    func displayScores() {
        print("displayScores")
//        vRootView.
        let vScoreBoard = UIView()
        vScoreBoard.tag = 60
        
        let svScores = UIStackView()
        var yPos = 0
        
        for thisPlayer in players {
            let myView = UIView()
            let labelName = UILabel()
            labelName.text = thisPlayer.name
            labelName.frame = CGRect(x: 0, y: yPos, width: 120, height: 30)
            let labelTricks = UILabel()
            labelTricks.text = "\(thisPlayer.tricksWon)/\(thisPlayer.tricksPlanned)"
            labelTricks.frame = CGRect(x: Int(labelName.frame.width + 10), y: yPos, width: 50, height: 30)
            let labelScore = UILabel()
            labelScore.text = "\(thisPlayer.score)"
            labelScore.frame = CGRect(x: Int(labelName.frame.width + labelTricks.frame.width + 20), y: yPos, width: 50, height: 30)
            
            myView.addSubview(labelName)
            myView.addSubview(labelTricks)
            myView.addSubview(labelScore)
            
            vScoreBoard.addSubview(myView)
            yPos += 40
        }
        vRootView.addSubview(vScoreBoard)
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
    
    func displayTrickBettingScreen() {
        print("displayTrickBettingScreen")
        let vBackGround = UIView()
        vCardView.isHidden = true
        vBackGround.tag = 70
        vBackGround.frame = CGRect(x: 20, y: 100, width: vRootView.frame.width - 40, height: vRootView.frame.height - 20)
        
        let vCardsOfPlayer = UIView()
        vCardsOfPlayer.tag = 71
        vCardsOfPlayer.frame = CGRect(x: 10, y: 10, width: vBackGround.frame.width - 20, height: 220)
        vBackGround.addSubview(vCardsOfPlayer)
        
        var offset = (Int(vCardsOfPlayer.frame.width) - (players[0].cards.count * 40 + 120)) / 2
        for thisCard in players[0].cards {
            let ivCard = UIImageView(image: UIImage(named: thisCard.id))
            ivCard.frame = CGRect(x: offset, y: 0, width: 140, height: 220)
            vCardsOfPlayer.addSubview(ivCard)
            offset += 40
        }
        
        let vBettingArea = UIView()
        vBettingArea.tag = 72
        vBettingArea.frame = CGRect(x: 10, y: 240, width: vBackGround.frame.width - 40, height: 160)
        vBackGround.addSubview(vBettingArea)
        
        let pxCenter = Int(vBettingArea.frame.width) / 2
        
        let btnMinus = UIButton()
        btnMinus.setTitle("-", for: .normal)
        btnMinus.setImage(UIImage(named: "btnMinus"), for: .normal)
        btnMinus.frame = CGRect(x: pxCenter - 100, y: 0, width: 45, height: 45)
        btnMinus.addTarget(self, action: #selector(btnAdjustTricks), for: .touchUpInside)
        btnMinus.tag = 0
        
        let btnPlus = UIButton()
        btnPlus.setTitle("+", for: .normal)
        btnPlus.setImage(UIImage(named: "btnPlus"), for: .normal)
        btnPlus.frame = CGRect(x: pxCenter + 55, y: 0, width: 45, height: 45)
        btnPlus.addTarget(self, action: #selector(btnAdjustTricks), for: .touchUpInside)
        btnPlus.tag = 1
        
        let labelNumber = UILabel()
        labelNumber.text = "0"
        labelNumber.font = UIFont(name: "Futura", size: 30)
        labelNumber.textAlignment = NSTextAlignment(CTTextAlignment.center)
        labelNumber.frame = CGRect(x: pxCenter - 22, y: 0, width: 44, height: 45)
        labelNumber.tag = 74
        
        var yPosPlayButton = 60
        if floppedTrumpCard?.value == 14 {
            let vColors = UIView()
            vColors.frame = CGRect(x: pxCenter-100, y: 50, width: 200, height: 50)
            
            var colors = ["Blue", "Green", "Red", "Yellow"]
            
            var thisOffset = 0
            for thisColor in colors {
                let btn = UIButton()
                btn.setTitle(thisColor, for: .selected)
                btn.setImage(UIImage(named: "btn\(thisColor)"), for: .normal)
                btn.frame = CGRect(x: thisOffset, y: 0, width: 50, height: 50)
                btn.addTarget(self, action: #selector(btnColor), for: .touchUpInside)
                thisOffset += 50
                vColors.addSubview(btn)
            }
            yPosPlayButton = 110
            vBettingArea.addSubview(vColors)
        }
        
        let btnBet = UIButton()
        btnBet.setTitle("play", for: .normal)
        btnBet.frame = CGRect(x: pxCenter - 102, y: yPosPlayButton, width: 200, height: 50)
        btnBet.setImage(UIImage(named: "btnBet"), for: .normal)
        btnBet.addTarget(self, action: #selector(btnAdjustTricks), for: .touchUpInside)
        btnBet.tag = 2
        
        vBettingArea.addSubview(btnMinus)
        vBettingArea.addSubview(labelNumber)
        vBettingArea.addSubview(btnPlus)
        vBettingArea.addSubview(btnBet)
        
        vRootView.addSubview(vBackGround)
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
        print("trick.winningCard: \(winningCard.id)")
        print("trick.winningPlayer: \(winningPlayer.name)")
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
    
    @objc func btnAdjustTricks(sender: UIButton!) {
        print("btnAdjustTricks")
        let labelNumber = vRootView.subviews.filter{$0.tag == 70}[0].subviews.filter{$0.tag == 72}[0].subviews.filter{$0.tag == 74}[0] as! UILabel
        var trickValue = Int(labelNumber.text!)
        
        if sender.tag == 0 {
            
            if trickValue! > 0 {
                labelNumber.text = String(trickValue! - 1)
            }
        }
        else if sender.tag == 1 {
            if trickValue! < currentRoundNumber {
                labelNumber.text = String(trickValue! + 1)
            }
        }
        else if sender.tag == 2 {
            players[0].tricksPlanned = Int(labelNumber.text!)!
            let viewToDiscard = vRootView.subviews.filter{$0.tag == 70}[0]
            viewToDiscard.isHidden = true
            viewToDiscard.removeFromSuperview()
            vCardView.isHidden = false
            updateTricksUI()
            newPlay()
        }
    }
    
    @objc func btnColor(sender: UIButton){
        let btn = sender
        var buttons = (sender.superview?.subviews)! as! [UIButton]
        for thisButton in buttons {

            thisButton.setImage(UIImage(named: "btn"+thisButton.title(for: .normal)!), for: .selected)
        }
        let image = "btn" + btn.title(for: .selected)! + "Active"
        btn.setImage(UIImage(named: image), for: .normal)
        trump = (btn.title(for: .normal)!)
    }
    

}
