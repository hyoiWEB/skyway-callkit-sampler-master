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
    

    @IBOutlet weak var adress: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBAction func signUp(_ sender: Any) {
        var addValue: String = adress.text!
        var passValue: String = pass.text!
        print("これがアドレスです",addValue)
        print("これがパスです",passValue)
        uservalue.insert(addValue, at: 0)
        uservalue.insert(passValue, at: 1)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        adress.resignFirstResponder()
        pass.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
        adress.delegate = self
        pass.delegate = self
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)

    }
}
