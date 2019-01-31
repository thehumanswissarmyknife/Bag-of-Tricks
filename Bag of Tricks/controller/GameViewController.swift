//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, CustomAlertViewDelegate, PlayerDelegate {
    
    // MARK: - global variables
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
    @IBOutlet weak var cHumanAreaBottom: NSLayoutConstraint!
    @IBOutlet weak var cLabelHumanArea: NSLayoutConstraint!
    @IBOutlet weak var lHumanArea: UILabel!
    @IBOutlet weak var vBtnScoreBoard: UIView!
    @IBOutlet weak var cScoreBoardRight: NSLayoutConstraint!
    @IBOutlet weak var btnScoreBoard: UIButton!
    
    
    @IBOutlet weak var vBettingrea: UIView!
    @IBOutlet weak var cBettingArea: NSLayoutConstraint!
    @IBOutlet weak var vBettingAreaColors: UIView!
    @IBOutlet weak var cBettingPlayButton: NSLayoutConstraint!
    
    @IBOutlet weak var lTricksBet: UILabel!
    
    // MARK: - LABELS FOR THE PLAYER AND HOW MANY TRICKS THEY WON IN THIS ROUND
    // labels for the players
    @IBOutlet weak var labelTricksPlayed: UILabel!
    @IBOutlet weak var labelWinner: UILabel!
    
    @IBOutlet weak var vPlayerTrickLabelArea: UIView!
    
    // MARK: - VARIABLES FOR THE GAME LOGIC
    // TODO: Userdefaults integration für name, anzahl player, highscores
    var defaults = UserDefaults.standard
    var myName = ""
    var dictHighScore: [String: Int] = [:]
    var roundsInTotal : Int = 0
    var currentRoundNumber : Int = 1    // correspondts to the number of cards dealt
    var tricksPlayedInRound : Int = 0      // how many of the tricks of the round have been played
    var playerIndexWhoStartsTheRound = 0
    
    var numberOfPlayers : Int = 3
    var players = [Player]()        // array holding the players. 0 is always the human in front of the device
    var playersInOrderOfTrick = [Player]() // this array gets shifted after each round
    var winningCard : Card = Card(thisColor: "blurp", thisValue: -1)
    var winningPlayer : Player = Player(thisName: "hansens", makeHuman: false)
    var trump : String = ""         // string with the trump color for the round
    var floppedTrumpCard : Card?    // the flopped card determining the trump
    var cardDeck = DeckOfCards()    // the card deck
    var cardsInTrick = [Card]()
    
    // MARK: - visual utilitz variables
    var humanAreaIsUp = false
    var scoreBoardIsVisible = false
    var bettingAreaIsVisible = false

    // MARK: - view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loading the userdefaults
        loadUserDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showCustomAlertInitScreen()
    }
    

    
    // MARK: - GAME FUNCTIONS
    func startGame() {
        print(".startGame")
        
        // create players
        // human player has id 0
        players.append(Player(thisName: myName, makeHuman: true))
        createPlayers(n: numberOfPlayers - 1)
        
        // add all players to the players in order array
        playersInOrderOfTrick = players
        
        // how many tricks - can be calculated byy
        roundsInTotal = cardDeck.shuffledCards.count / players.count
        
        // start the round
        startRound()
    }
    

    func startRound(){
        
        print("starting new nound")
//        print("\(players[playerIndexWhoStartsTheRound].name) is first to play")
        displayOneLineCustomAlert(for: "Dealer: \(playersInOrderOfTrick.last!.name)")
        
        cardDeck = DeckOfCards()
        clearCardsInTrick()
        updateScores()
        dealCards(howManyCards: currentRoundNumber)

        labelTricksPlayed.text = "TRICK \(currentRoundNumber)/\(roundsInTotal)"
        
        // shift the players so that the one who is supposed to start, is at index 0
        shiftPlayers(thisWinningPlayer: players[playerIndexWhoStartsTheRound])
        
        highlightDealerName()
        playersInOrderOfTrick.first?.calculateBestTrumpColor()
        
        // if the flopped card is a wizard, the first player has to choose the trump color
        if floppedTrumpCard!.value == 100 {
            if !playersInOrderOfTrick[0].isHuman{
                // for the moment pick a random color
                let colors = ["Blue", "Green", "Red", "Yellow"]
                playersInOrderOfTrick.first?.calculateBestTrumpColor()
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
//                displayTrickBettingScreen()
                displayPlayerCards()
                pushToggleBettingArea()
                
            }
        }
        
        displayPlayerTrickLabels()
    }
    
    func playTrick(){
        labelWinner.isHidden = true

        
        // this loop will go on till the number of tricks played is equal to the tricks in the round
        while tricksPlayedInRound < currentRoundNumber && playersInOrderOfTrick.count > 0 {
            // continuing playing the trick:
            // let the next player play his card
            
            if !playersInOrderOfTrick[0].isHuman && playersInOrderOfTrick[0].cards.count > 0{
                playersInOrderOfTrick[0].calcGenProbForAllCards()
                cardsInTrick.append(playersInOrderOfTrick[0].playCard(thisTrump: trump, theseCards: cardsInTrick))
                displayLastCardInTrick()
                
                playersInOrderOfTrick.removeFirst()
            }
            else {
                // human player! break from the loop
                // TODO: disply that the player should play a card
                displayOneLineCustomAlert(for: "Your turn \(players.first!.name)")
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
        if tricksPlayedInRound == currentRoundNumber && currentRoundNumber < roundsInTotal {
            // calculate the scores for this round
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
                updateScores()
                
            }
            // increase currentNumberOftricks
            currentRoundNumber += 1
            
            // set tricksplayed to 0
            tricksPlayedInRound = 0
            
            // start the next round: deal cards, have the players bet....
            vNextTrick.isHidden = false
                pushToggleScoreBoard()
            
            
            playerIndexWhoStartsTheRound += 1
            if playerIndexWhoStartsTheRound >= players.count {
                playerIndexWhoStartsTheRound -= players.count
            }
            
            
        }
            
            // after the last round display the total scores!
        else if tricksPlayedInRound == currentRoundNumber && currentRoundNumber == roundsInTotal {
            print("all rounds have been played, let's get the highscores")
            var scoreString = ""
            for thisplayer in players {
                if scoreString == "" {
                    scoreString = "\(thisplayer.name): \(thisplayer.score)\n"
                }
                else {
                    scoreString = scoreString + "\(thisplayer.name): \(thisplayer.score)\n"
                }
            }
            let thisScoreAlert = UIAlertController(title: "Final Score", message: scoreString, preferredStyle: .alert)
            thisScoreAlert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { _ in
                self.updateHighScore()
                self.startGame()
            }))
            thisScoreAlert.addAction(UIAlertAction(title: "No way, José", style: .cancel, handler: { (_) in
                self.updateHighScore()
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(thisScoreAlert, animated: true)
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
            floppedTrumpCard = Card(thisColor: "noTrump", thisValue: 0)
        }
        printPlayersCards()
    }

    
    // evaluate the cards in this trick
    func evaluateCardsInTrick(){
        print("evaluateCardsInTrick")
        // let's assunme that the first card is the winner and remove it from the array
        winningCard = cardsInTrick.removeFirst()
        
        for thisCard in cardsInTrick {
            
            // if the first card played is a wizard, it's won - break
            if winningCard.value == 100 {
                // Wizarsd always win
                break
            }
            
            // if thisCard is a wizard it wins, break
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
        displayOneLineCustomAlert(for: "\(winningPlayer.name) won")

        shiftPlayers(thisWinningPlayer: winningPlayer)
        displayPlayerTrickLabels()
    }

    // MARK: - UI UPDATING FUNCTIONS
    
    func pushToggleBettingArea(){
        if bettingAreaIsVisible {
            UIView.animate(withDuration: 0.5) {
                self.cBettingArea.constant += 200
                self.view.layoutIfNeeded()
            }
        }
        else {
            if floppedTrumpCard?.value == 100{
                vBettingAreaColors.isHidden = false
                cBettingPlayButton.constant = 50
                resetColorButtons()
            }
            else {
                cBettingPlayButton.constant = 10
                vBettingAreaColors.isHidden = true
            }
            lTricksBet.text = "0"
            UIView.animate(withDuration: 0.5) {
                self.cBettingArea.constant -= 200
                self.view.layoutIfNeeded()
            }
        }
        bettingAreaIsVisible = !bettingAreaIsVisible
    }
    
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
        
//        let widthOfCards = CARDWIDTHINHUMANAREA + ((theseCards.count-1) * 40)
        var initialOffset : Int = (Int(vCardView.frame.width) - (theseCards.count - 1) * 40 - CARDWIDTHINHUMANAREA)/2
        let addedPixel = 40
        
        for n in 0..<theseCards.count {
            let thisCard = theseCards[n]
            displayThisPlayerCard(thisCard: thisCard)
        }
//        playerCardsUpdate()
    }
    
    func displayThisPlayerCard(thisCard : Card) {
        let numberOfCardsDisplayed = vCardView.subviews.count
        let numberOfCardsTotal = players[0].cards.count

        var offsetOfThisCard = (Int(vCardView.frame.width) - Int(CARDWIDTHINHUMANAREA))/2 + (numberOfCardsDisplayed - (numberOfCardsTotal)/2)*40
        if numberOfCardsTotal % 2 == 0 {
            offsetOfThisCard += 20
        }
        let btnCard = createCardButton(for: thisCard)
        btnCard.frame = CGRect(x: Int(offsetOfThisCard), y: 0, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
        btnCard.isHidden = false
        
        vCardView.addSubview(btnCard)
        btnCard.frame.origin.x += 500
        btnCard.alpha = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
                btnCard.alpha = 1
                btnCard.frame.origin.x -= 500
                self.view.layoutIfNeeded()
            }) { (finished) in
                
            }
        }
    }

    func displayLastCardInTrick() {
        print("diplayLastCardInTrick")
        
        // for each card already on the table, the offset is 40
        let offsetX = (vCardsInTrick.subviews.count * 60)
        
        if cardsInTrick.count > 0 {
            let ivCard = createCardImage(for: cardsInTrick.last!)
            
            let playerPos = players.filter{$0.id == cardsInTrick.last!.playedByPlayer}.first?.position

            let posInView = CGRect(x: playerPos!, y: -CARDHEIGHTINHUMANAREA, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
            let posInVCardsInTrick = vRootView.convert(posInView, to: vCardsInTrick)
            ivCard.frame = posInVCardsInTrick
            
            if cardsInTrick.last?.playedByPlayer != 0 {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.vCardsInTrick.addSubview(ivCard)
                    ivCard.frame.origin = CGPoint(x: offsetX, y: 0)
                    self.view.layoutIfNeeded()
                }) { (finished) in
                
                }
            }
            else {
                
                ivCard.frame.origin.y = 0
                ivCard.frame.origin.x = CGFloat(offsetX)
                ivCard.alpha = 1
                self.vCardsInTrick.addSubview(ivCard)
            }
            
            
        }
        else {
            print(":::::: no cards in trick yet :::::::" )
        }
        

    }
    
    func playerCardsUpdate(){
        let theseViews = vCardView.subviews as! [UIButton]
        var offsetX = (Int(vCardView.frame.width) - (theseViews.count - 1) * 40 - CARDWIDTHINHUMANAREA)/2

        
        for thisView in theseViews {
//            print("offsetx: \(offsetX) for \(thisView.title(for: .selected))")
            let cardID = thisView.title(for: .selected)
            thisView.isEnabled = players[0].cards.filter{$0.id == cardID}[0].canBePlayed
            UIView.animate(withDuration: 0.2) {
                thisView.frame = CGRect(x: offsetX, y: 0, width: self.CARDWIDTHINHUMANAREA, height: self.CARDHEIGHTINHUMANAREA)
            }
            offsetX += 40
        }
        
    }
    
    // display the trump card
    func displayTrumpCard(){
        print("displayTrumpCard: \(floppedTrumpCard!.id)")
        
        vTrumpCard.addSubview(createCardImage(for: floppedTrumpCard!))
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
    func clearCardsInTrick() -> Bool{
        print("clearCardsInTrick")
        // clear all images from the view
        for cardView in vCardsInTrick.subviews {
            cardView.removeFromSuperview()
        }
        return true
    }
    
    // creates the labels for all players the first time around and afterwards, just updates them
    func displayPlayerTrickLabels(){
        if vPlayerTrickLabelArea.subviews.count > 0 {
            for n in 0..<players.count {
                let thisLabel = vPlayerTrickLabelArea.subviews[n] as! UILabel
                thisLabel.text = "\(players[n].name): \(players[n].tricksWon)/\(players[n].tricksPlanned)"
            }
        } else {

            let spacing = (Int(vPlayerTrickLabelArea.frame.width) - (players.count * 190)) / (players.count - 1)
            var offset = 10
            for thisPlayer in players {
                let thisLabel = UILabel()
                thisLabel.font = UIFont(name: "Futura", size: 25)
                thisLabel.text = "\(thisPlayer.name): \(thisPlayer.tricksWon)/\(thisPlayer.tricksPlanned)"
                thisLabel.frame = CGRect(x: offset, y: 0, width: 180, height: 50)
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
            if thisName == playersInOrderOfTrick.last?.name {
                thisLabel.textColor = colorRed
            } else {
                thisLabel.textColor = UIColor.black
            }
        }
    }
    
    // dependss on the variable of humanAreaIsUp
    func pushToggleHumanArea() {
        
        // if it's not up, then we push it up
        if !humanAreaIsUp {
            print("!humanAreaIsUp - going up")
            UIView.animate(withDuration: 1, animations: {
                self.cHumanAreaBottom.constant += 150
//                self.cLabelHumanArea.constant += 150
                self.fadeInLabel(thisLabel: self.lHumanArea, inSeconds: 0.5, withText: "HOW MANY TRICKS WILL YOU GET?")
                self.view.layoutIfNeeded()
            }) { (finished) in
                
            }
        }
        else if humanAreaIsUp {
            print("humanAreaIsUp - going down")
            UIView.animate(withDuration: 1, animations: {
                self.cHumanAreaBottom.constant -= 150
//                self.cLabelHumanArea.constant -= 150
                self.fadeInLabel(thisLabel: self.lHumanArea, inSeconds: 0.5, withText: "YOUR CARDS")
                self.view.layoutIfNeeded()
            }) { (finished) in
                self.displayPlayerCards()
            }
        }
        // flip the switch
        humanAreaIsUp = !humanAreaIsUp
    }
    
    
    
    // makes a label disappear and re-appear with a different text
    func fadeInLabel(thisLabel : UILabel, inSeconds: Double, withText: String?){
        UIView.animate(withDuration: inSeconds/2, animations: {
            thisLabel.alpha = 0
            self.view.layoutIfNeeded()
        }) { (finished) in
            UIView.animate(withDuration: inSeconds/2, animations: {
                thisLabel.text = withText
                thisLabel.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }

    
    // depends on the varialbe scoreBoardIsVisible
    func pushToggleScoreBoard(){
        
        if !scoreBoardIsVisible {
            print("!scoreBoardIsVisible - coming in")
            UIView.animate(withDuration: 0.5, animations: {
                self.cScoreBoardRight.constant += 330
                self.view.layoutIfNeeded()
            }) { (finished) in
                print("scoreboardIsVisible!!!")
            }
        }
        else if scoreBoardIsVisible {
            print("scoreBoardIsVisible - going away")
            UIView.animate(withDuration: 0.5, animations: {
                self.cScoreBoardRight.constant -= 330
                self.view.layoutIfNeeded()
            }) { (finished) in
                print("scoreBoard is hidden again")
                // check if this was the ast of the tricks, if so, start the next round
                if self.tricksPlayedInRound == 0 && self.vCardsInTrick.subviews.count == self.players.count {
                    self.btnNextTrick(self.btnScoreBoard)
                }
            }
        }
        scoreBoardIsVisible = !scoreBoardIsVisible
    }
    
    func showCustomAlertInitScreen(){
//        let customAlert = UIViewController(nibName: "CustomAlertViewController", bundle: nil) as! CustomAlertViewController
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "customAlertID") as! CustomAlertViewController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func displayOneLineCustomAlert(for thisText: String) {
        let oneLiner = self.storyboard?.instantiateViewController(withIdentifier: "OneLineOverlay") as! OneLineOverlayViewController
        oneLiner.text = thisText
        oneLiner.providesPresentationContextTransitionStyle = true
        oneLiner.definesPresentationContext = true
        oneLiner.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        oneLiner.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        DispatchQueue.main.async {
            self.present(oneLiner, animated: true, completion: nil)
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
    func resetColorButtons(){
        var colorButtons = vBettingAreaColors.subviews as! [UIButton]
        
        for thisButton in colorButtons {
            thisButton.setImage(UIImage(named: "btn"+thisButton.title(for: .selected)!), for: .normal)
        }
    }
    func backToMainMenu(){
        self.dismiss(animated: true, completion: nil)
    }
    func loadUserDefaults(){
        if let prefHighScore = defaults.dictionary(forKey: "highScore") as? [String:Int]{
            dictHighScore = prefHighScore
        }
        
        if let prefUserName = defaults.string(forKey: "userName") {
            myName = prefUserName
        }
        if let prefNumberOfPlayers = defaults.integer(forKey: "numberOfPlayers") as? Int {
            numberOfPlayers = prefNumberOfPlayers
        }
    }
    
    func updateHighScore(){
        // go through the dictionary and determine the min and max
        var max = 0
        var min = 0
        var minName = ""
        for (thisName, thisScore) in dictHighScore {
            if thisScore > max {
                max = thisScore
            }
            else if thisScore < min {
                min = thisScore
                minName = thisName
            }
        }
        if dictHighScore.count > 9 && players[0].score > min {
            dictHighScore.removeValue(forKey: minName)
            dictHighScore.updateValue(players[0].score, forKey: players[0].name)
        }
        else if players[0].score > min && dictHighScore.count < 10 {
            dictHighScore.updateValue(players[0].score, forKey: players[0].name)
        }
        defaults.set(dictHighScore, forKey: "highScore")
        
    }
    
    func updateScores(){

        print("updateScores")
        if vBtnScoreBoard.subviews.count > 1 {
            // whipe all subviews other than the button
            let theseViews = vBtnScoreBoard.subviews.filter{$0.tag == 11}
            
            for thisView in theseViews {
                thisView.removeFromSuperview()
            }
        }
        
        let thisFont = UIFont(name: "Futura", size: 25)
        let vScoreBoard = UIView()
        
        vScoreBoard.tag = 11
        
        var offsetY = 0
        let lPlayer = UILabel()
        lPlayer.text = "Player"
        lPlayer.font = thisFont
        lPlayer.tag = 11
        
        let lTricks = UILabel()
        lTricks.text = "Tricks"
        lTricks.font = thisFont
        lTricks.tag = 11
        
        let lScore = UILabel()
        lScore.text = "Score"
        lScore.font = thisFont
        lScore.tag = 11
        
        lPlayer.frame = CGRect(x: 0, y: offsetY, width: 120, height: 30)
        lTricks.frame = CGRect(x: 130, y: offsetY, width: 90, height: 30)
        lScore.frame = CGRect(x: 230, y: offsetY, width: 90, height: 30)
        offsetY = 40
        
        
        vScoreBoard.addSubview(lPlayer)
        vScoreBoard.addSubview(lTricks)
        vScoreBoard.addSubview(lScore)
        
        for thisPlayer in players {
            let smallFont = UIFont(name: "Futura", size: 25)
            let lPlayer = UILabel()
            lPlayer.text = thisPlayer.name
            lPlayer.font = smallFont
            lPlayer.tag = 11
            
            let lTricks = UILabel()
            lTricks.text = "\(thisPlayer.tricksWon) / \(thisPlayer.tricksPlanned)"
            lTricks.font = smallFont
            lTricks.tag = 11
            if thisPlayer.tricksPlanned != thisPlayer.tricksWon {
                lTricks.textColor = colorRed
                
            }
            else {
                lTricks.textColor = colorGreen
            }
            
            let lScore = UILabel()
            lScore.text = "\(thisPlayer.score)"
            lScore.font = smallFont
            lScore.textAlignment = NSTextAlignment.right
            lScore.tag = 11

            
            lPlayer.frame = CGRect(x: 0, y: offsetY, width: 120, height: 30)
            lTricks.frame = CGRect(x: 130, y: offsetY, width: 90, height: 30)
            lScore.frame = CGRect(x: 230, y: offsetY, width: 90, height: 30)
            vScoreBoard.addSubview(lPlayer)
            vScoreBoard.addSubview(lTricks)
            vScoreBoard.addSubview(lScore)
            offsetY += 30
        }
        vScoreBoard.frame = CGRect(x: 35, y: 40, width: 500, height: 10 + offsetY )
        vBtnScoreBoard.insertSubview(vScoreBoard, belowSubview: vNextTrick)
    }
    
    @IBAction func btnNextTrick(_ sender: UIButton) {
        print("btnNextTrick")

        vNextTrick.isHidden = true
        // check if we have to play the next trick or start a new round (dealing cards, etc.)
        if tricksPlayedInRound == 0  {
            if scoreBoardIsVisible {
                pushToggleScoreBoard()
            }
        
            startRound()
        }
        else {
            if clearCardsInTrick() {
                playTrick()
            }
        }
    }
    // function that is triggered, when a card is selected
    @objc func cardButtonPressed(sender: UIButton){
        print("pressedCard")

        let cardId = sender.title(for: .selected)

        let finalDestination = vRootView.convert(CGPoint(x: vCardsInTrick.subviews.count * 60, y: 0), from: vCardsInTrick)
        
        let frame = vRootView.convert(sender.frame, from:vCardView)
        
        vRootView.addSubview(sender)
        sender.frame = frame
        
//        animatePlayingCard(thisCard: Card(thisColor: "Blue", thisValue: 12), from: sender.frame.origin, to: finalDestination)
        
//         bundle this ina afunction: playCardOfPlayer. generating the card at the origin of the player and move it to the cardsInTrickArea
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.frame = CGRect(origin: finalDestination, size: CGSize(width: sender.frame.width, height: sender.frame.height))
            self.view.layoutIfNeeded()
        }) { (finished) in
            sender.removeFromSuperview()
            self.cardsInTrick.append(self.playersInOrderOfTrick[0].playThisCard(thisCardID: cardId!))
            self.displayLastCardInTrick()
            self.playerCardsUpdate()
            self.playersInOrderOfTrick.removeFirst()

            self.playTrick()
        }
        
    }
    
    func animatePlayingCard(thisCard: Card, from origin: CGPoint, to destination: CGPoint) {
        let thisCardImage = createCardImage(for: thisCard)
        let cardSize = CGSize(width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
        thisCardImage.frame = CGRect(origin: origin, size: cardSize)
        
        let deltaX = origin.x - destination.x
        let deltaY = origin.y - destination.y
        
        let delta = atan(Double(-deltaX)/Double(deltaY))
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseInOut, animations: {
            thisCardImage.frame = CGRect(origin: destination, size: cardSize)
            thisCardImage.transform = CGAffineTransform(rotationAngle: CGFloat(delta))
        }) { (finished) in
            self.cardsInTrick.append(self.playersInOrderOfTrick[0].playThisCard(thisCardID: thisCard.id))
            self.displayLastCardInTrick()
            self.playerCardsUpdate()
            self.playersInOrderOfTrick.removeFirst()
        }
    }
    
    func disablePlayerCards(){
        for thisCardbutton in vCardView.subviews {
            let btn = thisCardbutton as! UIButton
            btn.isEnabled = false
        }
    }
    
    func enablePlayerCards(){
        for thisCardbutton in vCardView.subviews {
            let btn = thisCardbutton as! UIButton
            btn.isEnabled = true
        }
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
        let spacing = (Int(view.frame.width) / (n+1))
        // some names, that are picked at random
        var playerNames = ["Peter", "Louise", "Claudia", "Roberto", "Michael", "Celine", "Paula", "Elvira", "Daniel", "Francesca"]
        for p in 1...n {
            let random = Int.random(in: 0..<playerNames.count)
            let aPlayer = Player(thisName: playerNames.remove(at: random), thisLevel: "easy", thisID: random+1, thisPosition: (spacing * p)-(CARDWIDTHINHUMANAREA/2))
            aPlayer.delegate = self
            players.append(aPlayer)
        }
    }
    
    func createCardButton(for thisCard: Card) -> UIButton {
        
        let btnCard = UIButton()
        btnCard.isHidden = true
        btnCard.setImage(UIImage(named: thisCard.id.lowercased()), for: .normal)
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
        ivCardFace.frame = CGRect(x: 0, y: 0, width: CARDWIDTHINHUMANAREA, height: CARDHEIGHTINHUMANAREA)
        ivCard.addSubview(ivCardBackGround)
        ivCard.addSubview(ivCardFace)
        
        return ivCard
    }
    
    @IBAction func btnBetTrickAdjust(_ sender: UIButton) {
        let trickValue = Int(lTricksBet.text!)
        
        if sender.tag == 0 {
            if trickValue! > 0 {
                lTricksBet.text = "\(trickValue! - 1)"
            }
        }
        else if sender.tag == 1 {
            if trickValue! < currentRoundNumber {
                lTricksBet.text = String(trickValue! + 1)
            }
        }
        else if sender.tag == 2 {
            players[0].tricksPlanned = Int(lTricksBet.text!)!
            print("playbutton pressed")
            
            displayTrumpCard()
//            let viewToDiscard = sender.superview!
//            viewToDiscard.removeFromSuperview()
//            pushToggleHumanArea()
            pushToggleBettingArea()
            displayPlayerTrickLabels()
            playTrick()
        }
    }
    
    
    @objc func btnAdjustTricks(sender: UIButton!) {
        print("btnAdjustTricks")
        
        let labelNumber = sender.superview?.subviews.filter{$0.tag == 74}.first as! UILabel
        let trickValue = Int(labelNumber.text!)
        
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
            // means the user wants to play
        else if sender.tag == 2 {
            players[0].tricksPlanned = Int(labelNumber.text!)!
            
            displayTrumpCard()
            let viewToDiscard = sender.superview!
            viewToDiscard.removeFromSuperview()
            pushToggleHumanArea()
            displayPlayerTrickLabels()
            playTrick()
        }
    }
    
    @IBAction func btnTrumpColor(_ sender: UIButton) {
        let btn = sender
        print("btnTrumpColor: \(btn.title(for: .selected))")
        let buttons = (sender.superview?.subviews)! as! [UIButton]
        for thisButton in buttons {
            thisButton.setImage(UIImage(named: "btn"+thisButton.title(for: .selected)!), for: .normal)
        }
        let image = "btn" + btn.title(for: .selected)! + "Active"
        btn.setImage(UIImage(named: image), for: .normal)
        trump = (btn.title(for: .selected)!)
        floppedTrumpCard = Card(thisColor: trump, thisValue: 15)
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
    @IBAction func btnPressedScoreBoard(_ sender: UIButton) {
        print("btnPressedScoreBoard")
        pushToggleScoreBoard()
//        pushHideScoreBoard(hide: true)
    }
    
    @IBAction func btnPressedAbort(_ sender: UIButton) {
        
        // TODO: add alert with question
        self.dismiss(animated: true, completion: nil)
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
