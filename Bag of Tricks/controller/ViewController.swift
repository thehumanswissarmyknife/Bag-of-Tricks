//
//  ViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let player1 = Player(thisName: "Frank", thisLevel: "easy", thisID : 11)
        let player2 = Player(thisName: "Peter", thisLevel: "easy", thisID : 21)
        let player3 = Player(thisName: "Louise", thisLevel: "easy", thisID : 31)
        
        let myPlayers = [player1, player2, player3]
        
        let myBagOfTricks = BagOfTricks(theseManyTricks : 5, thisTrump : "green", thesePlayers : myPlayers)
        
        
        myBagOfTricks.playBag()
    }


}

