//
//  HumanPlayer.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 03.02.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import Foundation

class HumanPlayer : Player {
    var sortingOrderAscending : Bool = true
    
    var defaults = UserDefaults.standard
    
    var sortBlueValue : Int = 4
    var sortRedValue : Int = 3
    var sortGreenValue : Int = 5
    var sortYellowValue : Int = 6
    var sortBlackValue : Int = 0
    
    
    
    init(thisName: String) {
        super.init(thisName: thisName, makeHuman: true)
        
        if let prefColorSorting = defaults.array(forKey: "colorSorting") as? [String]{
            colorSorting = prefColorSorting
        }
        
        if let prefSortingOrderAscending = defaults.bool(forKey: "sortingOrder") as? Bool{
            sortingOrderAscending = prefSortingOrderAscending
        }
    }
    
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
    
    func playThisCard(thisCardID : String) -> Card{
        
        print("\(name).playThisCard(\(thisCardID))")
        
        let cardToPlay = cards.filter{$0.id == thisCardID}[0]
        cards = cards.filter{$0 !== cardToPlay}
        
        return cardToPlay
    }
    
}
