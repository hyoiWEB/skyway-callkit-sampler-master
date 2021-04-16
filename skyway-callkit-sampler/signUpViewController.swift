//
//  signUpViewController.swift
//  skyway-callkit-sampler
//
//  Created by hikaru watanabe on 10.3.2021.
//  Copyright © 2021 yorifuji. All rights reserved.
//

import Foundation
import UIKit

var uservalue:Array<String> = []
var changelog:Bool=false
var updateJudge:Bool=false

class signUpViewController: UIViewController, UITextFieldDelegate {

    let userDefaults = UserDefaults.standard
    var defaultMail:String!
    var gmailaddress:String?=UserDefaults.standard.string(forKey: "usedMailAddress")
//    var gmailaddress:String=uservalue[0]
//    var gmailpass:String=uservalue[1]
    let mailOfSender:String="usingfordevelop@gmail.com"
    let passOfSender:String="*umiush1"
    var peeridValue=UserDefaults.standard.string(forKey: "peerID") ?? nil
    
    
    @IBOutlet weak var lastTimeAddress: UILabel!
    
    @IBOutlet weak var adress: UITextField!

    
    @IBAction func tapNextButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        userDefaults.set(true, forKey: "buttonCheck")
        changelog=true
        updateJudge=true
    }
    

    
    
    @IBAction func signUp(_ sender: Any) {
        let addValue: String = adress.text!
        print("これがアドレスです",addValue)
        uservalue.insert(addValue, at: 0)
        UserDefaults.standard.set(addValue, forKey: "usedMailAddress")
        lastTimeAddress.text = UserDefaults.standard.string(forKey: "usedMailAddress")
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        adress.resignFirstResponder()

        return true
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        adress.delegate = self
        
       
        lastTimeAddress.text = UserDefaults.standard.string(forKey: "usedMailAddress")
        
        defaultMail = UserDefaults.standard.string(forKey: "usedMailAddress")
        uservalue.insert(defaultMail, at: 0)
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }
}
