//
//  OneLineOverlayViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 17.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

class OneLineOverlayViewController: UIViewController {

    @IBOutlet weak var lText: UILabel!
    var text : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if text != nil {
            lText.text = text
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fadeIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func fadeIn(){
        lText.alpha = 0
        self.lText.frame.origin.y += 50
        UIView.animate(withDuration: 0.4, animations: {
            self.lText.alpha = 1
            self.lText.frame.origin.y -= 50
        }) { (finished) in
            print("view animated")
            self.fadeOut()
        }
    }
    
    func fadeOut(){
        UIView.animate(withDuration: 0.4, delay: 0.8, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.lText.alpha = 0
        }) { (finished) in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
