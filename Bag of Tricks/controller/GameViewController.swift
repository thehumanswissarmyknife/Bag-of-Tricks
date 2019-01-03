//
//  GameViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 02.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var vCardView: UIView!
    var myCardArray = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myDeckOfCards = DeckOfCards()
        
        
        
        for _ in 1...20 {
            myCardArray.append(myDeckOfCards.dealCard())
        }
        var thisX : Int = 20
        
        let widthOfView = vCardView.frame.width - 40 - 80
        
        let addedPixel = Int(widthOfView) / myCardArray.count
        
        for n in 0..<myCardArray.count {
            let thisCard = myCardArray[n]
            print("cfreate button \(thisCard.id)")
            var btnCard = UIButton()
            btnCard.setImage(UIImage(named: thisCard.id), for: .normal)
            btnCard.frame = CGRect(x: thisX, y: 10, width: 140, height: 220)
            btnCard.tintColor = UIColor.brown
            btnCard.setTitle("\(thisCard.id)", for: .normal)
            btnCard.tag = 100 + n
            btnCard.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
            vCardView.addSubview(btnCard)
            
            thisX += addedPixel
        }
        
        vCardView.reloadInputViews()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func pressed(sender: UIButton){
        let inndex = sender.tag - 100
        
        print("\(sender.tag)")
        if inndex < myCardArray.count {
            print("Button pressed Tag:\(myCardArray[inndex].id)")
        }
        
    }
}
