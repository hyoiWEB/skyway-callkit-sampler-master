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


class signUpViewController: UIViewController, UITextFieldDelegate {

    let userDefaults = UserDefaults.standard
    var defaultMail:String!
    
    
    
    
    @IBOutlet weak var lastTimeAddress: UILabel!
    
    @IBOutlet weak var adress: UITextField!

    
    @IBAction func tapNextButton(_ sender: Any) {
      
    }
    

    
    
    @IBAction func signUp(_ sender: Any) {
        var addValue: String = adress.text!
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
        
        userDefaults.register(defaults: ["usedMailAddress":"まずは新しい接続先を編集してください！"])
        lastTimeAddress.text = UserDefaults.standard.string(forKey: "usedMailAddress")
        
        defaultMail = UserDefaults.standard.string(forKey: "usedMailAddress")
        uservalue.insert(defaultMail, at: 0)
        
    }
    
    
        

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)

    }
}
