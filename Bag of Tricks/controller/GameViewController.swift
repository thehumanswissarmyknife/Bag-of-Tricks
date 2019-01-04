//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // TODO: Userdefaults integration für name, anzahl player...
    var defaults = UserDefaults.standard

    // MARK: OUTLETS FOR THE UI
    @IBOutlet var vRootView: UIView!
    @IBOutlet weak var vParkingLot: UIView!
    @IBOutlet weak var ivTrumpCard: UIImageView!
    
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
    
    @IBOutlet weak var labelPlayerOne: UILabel!
    @IBOutlet weak var labelPlayerYou: UILabel!
    @IBOutlet weak var labelPlayerTwo: UILabel!
    @IBOutlet weak var labelPlayerThree: UILabel!
    @IBOutlet weak var labelPlayerFour: UILabel!
    
    // MARK: - Modalview
    // TODO: ALERT
    @IBOutlet weak var vModalView: UIView!
    @IBOutlet weak var btnPlayGame: UIButton!
    

    // modaler View für die bestimmung der Spieleranzahl
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var vCardView: UIView!
    var myCardArray = [Card]()
    var players = [Player]()
    
    var myName = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myDeckOfCards = DeckOfCards()
        
//        vModalView.isHidden = false
//        vRootView.addSubview(vModalView)
        
        // TODO: create alert style window for input
        createPlayers(n: 2)
        
        /* TODO: refactor all functionality to the gameController:
         this way it's easier to trigger the play-input and hae all variables at hand
         
         -> bagOfTricks
         -> playerArray
         -> each trick
         -> all loops through the rounds are in the main game controller
         */

        
        for n in 0..<20 {
            myCardArray.append(myDeckOfCards.dealCard())
        }
        
        displayPlayerCards(theseCards: myCardArray)
        
        vCardView.reloadInputViews()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    
    @objc func pressed(sender: UIButton){
        let inndex = sender.tag - 100
        
        print("\(sender.tag)")
        if inndex < myCardArray.count {
            print("Button pressed Tag:\(myCardArray[inndex].id)")
        }
        
    }
    
    // MARK: - REAL FUNCTIONS
    func startGame() {
        // TODO: create the bagOfTricks
        // TODO: start the game
    }
    
    func createPlayers (n : Int) {
        // some names, that are picked at random
        var playerNames = ["Peter", "Louise", "Claudia", "Roberto", "Michael", "Celine", "Paula", "Elvira", "Daniel", "Francesca"]
        for _ in 1...n {
            let random = Int.random(in: 0..<playerNames.count)
            let aPlayer = Player(thisName: playerNames.remove(at: random), thisLevel: "easy", thisID: random+1)
            players.append(aPlayer)
        }
    }
    
    // MARK: - Functions for the player
    
    func displayPlayerCards(theseCards : [Card]){
        
        let widthOfCards = 120 + (theseCards.count * 40)
        let widthOfView = vCardView.frame.width - 40
        var initialOffset : Int = ((Int(widthOfView) - widthOfCards) / 2)
        let addedPixel = 40
        
        for n in 0..<theseCards.count {
            let thisCard = myCardArray[n]
            print("cfreate button \(thisCard.id)")
            var btnCard = UIButton()
            btnCard.setImage(UIImage(named: thisCard.id), for: .normal)
            btnCard.frame = CGRect(x: initialOffset, y: 10, width: 140, height: 220)
            btnCard.tintColor = UIColor.brown
            btnCard.setTitle("\(thisCard.id)", for: .normal)
            btnCard.tag = 100 + n
            btnCard.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
            vCardView.addSubview(btnCard)
            
            initialOffset += addedPixel
        }
    }
    
    
    @IBAction func btnPlayGamePressed(_ sender: UIButton) {
        myName = tfName.text!
        labelPlayerYou.text = "\(myName): -/15"
        defaults.set(myName, forKey:"playerName")
        vModalView.isHidden = true
        vParkingLot.addSubview(vModalView)
    }
}
