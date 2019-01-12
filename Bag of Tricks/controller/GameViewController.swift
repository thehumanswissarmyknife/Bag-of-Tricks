//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - global variables
//    let CARDWIDTHINPLAYAREA =  163
//    let CARDHEIGHTINPLAYAREA = 256
    
    let CARDHEIGHTINHUMANAREA = 300
    let CARDWIDTHINHUMANAREA = 191
    
    // MARK: - COLORS
    let colorBlue = UIColor(rgb: 0x2980b9)
    let colorGreen = UIColor(rgb: 0x27ae60)
    let colorRed = UIColor(rgb: 0xe74c3c)
    let colorYellow = UIColor(rgb: 0xf1c40f)
    let colorDarkGrey = UIColor(rgb: 0x636e72)
    let colorLightGrey = UIColor(rgb: 0xb2bec3)
    let colorLightestGrey = UIColor(rgb: 0xdfe6e9)
    
    
    // MARK: OUTLETS FOR THE UI
    @IBOutlet var vRootView: UIView!
    @IBOutlet weak var vTrumpCard: UIView!
    @IBOutlet weak var vNextTrick: UIButton!
    @IBOutlet weak var vCardView: UIView!
    @IBOutlet weak var vCardsInTrick: UIView!
    @IBOutlet weak var vHumanArea: UIView!
    
    
    // MARK: - LABELS FOR THE PLAYER AND HOW MANY TRICKS THEY WON IN THIS ROUND
    // labels for the players
    @IBOutlet weak var labelTricksPlayed: UILabel!
    @IBOutlet weak var labelWinner: UILabel!
    
    @IBOutlet weak var vPlayerTrickLabelArea: UIView!
    
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
//        displayPlayerTrickLabels()
        
        cardDeck = DeckOfCards()
        clearCardsInTrick()
        dealCards(howManyCards: currentRoundNumber)
        
        
        labelTricksPlayed.text = "TRICK \(currentRoundNumber)/\(roundsInTotal)"
        
        // shift the players so that the one who is supposed to start, is at index 0
        shiftPlayers(thisWinningPlayer: players[playerIndexWhoStartsTheRound])
        
        highlightDealerName()
        
        // if the flopped card is a wizard, the first player has to choose the trump color
        if floppedTrumpCard!.value == 100 {
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
        
        displayPlayerTrickLabels()
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
                players[0].sortCards()
                break
            }
        }

        // if all cards have been played
        if playersInOrderOfTrick.count == 0 {
            // evaluate trick -> sets winningCard and winningPlayer
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
                
            }
            
            cardsInTrick.removeAll()
        }
        
        // if all tricks of the round have been played
        if tricksPlayedInRound == currentRoundNumber {
            // evaluate this round
//            displayScores()
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
            if winningCard.value == 100 {
                // Wizarsd always win
                break
            }
            
            if thisCard.value == 100 {
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
        shiftPlayers(thisWinningPlayer: winningPlayer)
        displayPlayerTrickLabels()
    }

    // MARK: - UI UPDATING FUNCTIONS
    
    // displays the cards of the human player in the card array.
    // each card is a button
    func displayPlayerCards(){
        print("displayPlayerCards")
        // human player is always the first in the players array
        
        players[0].sortCards()
        let theseCards = players[0].cards

        for thisCardView in vCardView.subviews {
            thisCardView.removeFromSuperview()
        }
        
        let widthOfCards = CARDWIDTHINHUMANAREA + (theseCards.count * 40)
        let widthOfView = vCardView.frame.width - 40
        var initialOffset : Int = ((Int(widthOfView) - widthOfCards) / 2)
        let addedPixel = 40
        
        for n in 0..<theseCards.count {
            let thisCard = theseCards[n]
//            print("create button \(thisCard.id.lowercased())")
            
            let btnCard = createCardButton(for: thisCard)
            btnCard.frame = CGRect(x: initialOffset, y: 10, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)

            vCardView.addSubview(btnCard)
            
            initialOffset += addedPixel
        }
    }
    
    func displayScores() {
        print("displayScores")
//        vRootView.
        
        let middleX = Int(vRootView.frame.width) / 2
        
        let vTheScoreBoard = UIView()
        vTheScoreBoard.tag = 50
        
        vTheScoreBoard.frame = CGRect(x:  middleX - 945/2, y: 100, width: 945, height: 400)
        let ivScoreBoard = UIImageView(image: UIImage(named: "scoreBoard"))
        ivScoreBoard.frame = CGRect(x:  0, y: 0, width: 945, height: 508)
        vTheScoreBoard.addSubview((ivScoreBoard))
        vRootView.addSubview(vTheScoreBoard)
        
        let btnNextRound = UIButton()
        btnNextRound.setImage(UIImage(named: "btnNextRound"), for: .normal)
        btnNextRound.frame = CGRect(x: middleX - 269/2, y: 300, width: 269, height: 60)
        btnNextRound.addTarget(self, action: #selector(btnNextRoundAfterScores), for: .touchUpInside)
        vTheScoreBoard.addSubview((btnNextRound))
        
        let svScores = UIStackView()
        var yPos = 50
        
        let labelTheScore = UILabel()
        labelTheScore.text = "Scores after \(currentRoundNumber) of \(roundsInTotal)"
        labelTheScore.font = UIFont(name: "Futura", size: 30)
        vTheScoreBoard.addSubview(labelTheScore)
        
        for thisPlayer in players {
            let myView = UIView()
            
            let labelName = UILabel()
            labelName.text = thisPlayer.name
            labelName.frame = CGRect(x: 20, y: yPos, width: 150, height: 25)
            labelName.font = UIFont(name: "Futura", size: 30)
            let labelTricks = UILabel()
            labelTricks.text = "\(thisPlayer.tricksWon)/\(thisPlayer.tricksPlanned)"
            labelTricks.frame = CGRect(x: Int(labelName.frame.width + 20), y: yPos, width: 80, height: 25)
            labelTricks.font = UIFont(name: "Futura", size: 30)
            let labelScore = UILabel()
            labelScore.text = "\(thisPlayer.score)"
            labelScore.frame = CGRect(x: Int(labelName.frame.width + labelTricks.frame.width + 40), y: yPos, width: 80, height: 25)
            labelScore.font = UIFont(name: "Futura", size: 30)
            
            myView.addSubview(labelName)
            myView.addSubview(labelTricks)
            myView.addSubview(labelScore)
            
            vTheScoreBoard.addSubview(myView)
            yPos += 40
        }
        vRootView.addSubview(vTheScoreBoard)
    }

    // display the cards in the current trick
    func displayCardsInTrick(){
        print("displayCardsInTrick")
        clearCardsInTrick()
        var offset = 0
        for thisCard in cardsInTrick {
            let vCardPlusName = UIView()
            
            let ivCard = createCardImage(for: thisCard)
            let labelName = UILabel()
            
            labelName.text = players.filter{$0.id == thisCard.playedByPlayer}[0].name
            labelName.font = UIFont.init(name: "Futura", size: 20)
            labelName.textColor = UIColor.black
            labelName.textAlignment = NSTextAlignment.center
            
            ivCard.frame = CGRect(x: offset, y: 0, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
            labelName.frame = CGRect(x: offset, y: CARDHEIGHTINHUMANAREA + 20, width: CARDWIDTHINHUMANAREA, height: 30)
            
            vCardPlusName.addSubview(ivCard)
            vCardPlusName.addSubview(labelName)
            vCardsInTrick.addSubview(vCardPlusName)
            offset += CARDWIDTHINHUMANAREA + 20
        }
    }
    
    func displayTrickBettingScreen() {
        
        print("displayTrickBettingScreen")
        let vBackGround = UIView()
        vCardView.isHidden = true
        vBackGround.tag = 70
        vBackGround.frame = CGRect(x: 20, y: 180, width: vRootView.frame.width - 40, height: vRootView.frame.height - 20)
        
        let vCardsOfPlayer = UIView()
        vCardsOfPlayer.tag = 71
        vCardsOfPlayer.frame = CGRect(x: 10, y: 10, width: Int(vBackGround.frame.width - 20), height: CARDHEIGHTINHUMANAREA)
        vBackGround.addSubview(vCardsOfPlayer)
        
        players[0].sortCards()
        var offset = (Int(vCardsOfPlayer.frame.width) - (players[0].cards.count * 40 + 120)) / 2
        for thisCard in players[0].cards {
            let ivCard = createCardImage(for: thisCard)
            ivCard.frame = CGRect(x: offset, y: 0, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
            vCardsOfPlayer.addSubview(ivCard)
            offset += 40
        }
        
        let vBettingArea = UIView()
        vBettingArea.tag = 72
        vBettingArea.frame = CGRect(x: 10, y: 240, width: Int(vBackGround.frame.width - 40), height: CARDHEIGHTINHUMANAREA + 20)
        vBackGround.addSubview(vBettingArea)
        
        let pxCenter = Int(vBettingArea.frame.width) / 2
        
        let btnMinus = UIButton()
        btnMinus.setTitle("-", for: .selected)
        btnMinus.setImage(UIImage(named: "btnMinus"), for: .normal)
        btnMinus.frame = CGRect(x: pxCenter - 100, y: 0, width: 45, height: 45)
        btnMinus.addTarget(self, action: #selector(btnAdjustTricks), for: .touchUpInside)
        btnMinus.tag = 0
        
        let btnPlus = UIButton()
        btnPlus.setTitle("+", for: .selected)
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
        if floppedTrumpCard?.value == 100 {
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
        print("displayTrumpCard: \(floppedTrumpCard!.id)")
        
        vTrumpCard.addSubview(createCardImage(for: floppedTrumpCard!))
    }
    
    
    // updates how many tricks each player has won vs planned
//    func updateTricksUI(){
//        print("updateTricksUI")
//        displayPlayerTrickLabels()
////        for n in 0..<players.count {
////            playerLabels[n].text = "\(players[n].name): \(players[n].tricksWon)/\(players[n].tricksPlanned)"
////            playerLabels[n].isHidden = false
////        }
//    }
    
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
    
    // creates the labels for all players the first time around and afterwards, just updates them
    func displayPlayerTrickLabels(){
        if vPlayerTrickLabelArea.subviews.count > 0 {
            for n in 0..<players.count {
                let thisLabel = vPlayerTrickLabelArea.subviews[n] as! UILabel
                thisLabel.text = "\(players[n].name): \(players[n].tricksWon)/\(players[n].tricksPlanned)"
                
                // TODO: color the player who is playing next, red!
                
            }
        } else {

            let spacing = (Int(vPlayerTrickLabelArea.frame.width) - (players.count * 220)) / (players.count - 1)
            var offset = 10
            for thisPlayer in players {
                let thisLabel = UILabel()
                thisLabel.font = UIFont(name: "Futura", size: 25)
                thisLabel.text = "\(thisPlayer.name): \(thisPlayer.tricksWon)/\(thisPlayer.tricksPlanned)"
                thisLabel.frame = CGRect(x: offset, y: 0, width: 200, height: 50)
                vPlayerTrickLabelArea.addSubview(thisLabel)
                offset += spacing + Int(thisLabel.frame.width)
            }
        }
        
    }
    
    func highlightDealerName(){
        print("highlightDealerName")
        let labelArray = vPlayerTrickLabelArea.subviews
        
        for thisView in labelArray {
            let thisLabel = thisView as! UILabel
            var thisName = thisLabel.text!
            thisName = String(thisName.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)[0])
            print(thisName)
            if thisName == playersInOrderOfTrick.last?.name {
                thisLabel.textColor = colorRed
            } else {
                thisLabel.textColor = UIColor.black
            }
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
    @objc func cardButtonPressed(sender: UIButton){
        print("pressedCard")
        let index = sender.tag - 100       // the cards start with the tag 100
        let cardId = sender.title(for: .selected)
        
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
    
    func createCardButton(for thisCard: Card) -> UIButton {
        
        let btnCard = UIButton()
        btnCard.setImage(UIImage(named: thisCard.id.lowercased()), for: .normal)
        btnCard.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btnCard.imageView?.contentMode = .scaleAspectFill
        btnCard.setBackgroundImage(UIImage(named: "bgWhite"), for: .normal)
        btnCard.setBackgroundImage(UIImage(named: "bgDisabled"), for: .disabled)
        btnCard.setTitle("\(thisCard.id)", for: .selected)
        btnCard.isEnabled = thisCard.canBePlayed
        btnCard.addTarget(self, action: #selector(cardButtonPressed(sender:)), for: .touchUpInside)
        
        return btnCard
    }
    
    func createCardImage(for thisCard: Card) -> UIView {
        let ivCard = UIView()
        let ivCardBackGround = UIImageView(image: UIImage(named: "bgWhite"))
        ivCardBackGround.frame = CGRect(x: 0, y: 0, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
        let ivCardFace = UIImageView(image: UIImage(named: thisCard.id))
        ivCardFace.frame = CGRect(x: 5, y: 5, width: CARDWIDTHINHUMANAREA - 10, height: CARDHEIGHTINHUMANAREA - 10)
        ivCard.addSubview(ivCardBackGround)
        ivCard.addSubview(ivCardFace)
        
        return ivCard
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
            displayPlayerTrickLabels()
            newPlay()
        }
    }
    
    @objc func btnColor(sender: UIButton){
        let btn = sender
        let buttons = (sender.superview?.subviews)! as! [UIButton]
        for thisButton in buttons {

            thisButton.setImage(UIImage(named: "btn"+thisButton.title(for: .selected)!), for: .selected)
        }
        let image = "btn" + btn.title(for: .selected)! + "Active"
        btn.setImage(UIImage(named: image), for: .normal)
        trump = (btn.title(for: .selected)!)
        floppedTrumpCard = Card(thisColor: trump, thisValue: 15)
    }
    
    @objc func btnNextRoundAfterScores(sender: UIButton){
        let theView = vRootView.subviews.filter{$0.tag == 50}[0]
        theView.removeFromSuperview()
    }
    

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
