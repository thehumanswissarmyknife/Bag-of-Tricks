//
//  CustomAlertViewController.swift
//  Bag of Tricks
//
//  Created by Dennis Vocke on 17.01.19.
//  Copyright © 2019 Dennis Vocke. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    var myName : String {get set}
    var numberOfPlayers : Int {get set}
    
    func startGame()
    func backToMainMenu()
    
}
class CustomAlertViewController: UIViewController {
    
    var defaults = UserDefaults.standard

    @IBOutlet weak var vCustomAlertView: UIView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var vOpponents: UIView!
    @IBOutlet weak var lNumberOfPlayers: UILabel!
    
    @IBOutlet weak var vBtnStepperOpponents: UIStepper!
    
    var delegate: CustomAlertViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vBtnStepperOpponents.minimumValue = 3
        vBtnStepperOpponents.maximumValue = 5
        
        tfName.becomeFirstResponder()
        if let prefUserName = defaults.string(forKey: "userName") {
            tfName.text = prefUserName
        }
        if let prefNumberOfPlayers = defaults.integer(forKey: "numberOfPlayers") as? Int {
            lNumberOfPlayers.text = "\(prefNumberOfPlayers)"
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView(){
//        vCustomAlertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView(){
        vCustomAlertView.alpha = 0
        self.vCustomAlertView.frame.origin.y += 50
        UIView.animate(withDuration: 0.4, animations: {
            self.vCustomAlertView.alpha = 1
            self.vCustomAlertView.frame.origin.y -= 50
        }) { (finished) in
            print("view animated")
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnStepperOpponents(_ sender: UIStepper) {
        print("stepper is pressed: \(sender.value)")
        lNumberOfPlayers.text = Int(sender.value).description
    }
    @IBAction func btnPressedPlay(_ sender: UIButton) {
        vCustomAlertView.resignFirstResponder()
        delegate?.myName = self.tfName.text!
        delegate?.numberOfPlayers = Int(self.lNumberOfPlayers.text!)!
        delegate?.startGame()
        defaults.set(Int(self.lNumberOfPlayers.text!)!, forKey: "numberOfPlayers")
        defaults.set(self.tfName.text!, forKey:"userName")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPressedBack(_ sender: UIButton) {
        vCustomAlertView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
}
