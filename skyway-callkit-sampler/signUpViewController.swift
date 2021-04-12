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
    
    
//    func sendEmail() {
//        print("ボタンが押されました")
//        // Gmailの場合、Gmail側の設定で安全性の低いアプリへのアクセスを無効 -> 有効にする必要がある
//        let smtpSession = MCOSMTPSession()
//        smtpSession.hostname = "smtp.gmail.com"
//        smtpSession.username = mailOfSender
//        print("Gmailアドレス：",mailOfSender)
//        // 送信元のSMTPサーバーのusername（Gmailアドレス）
//        smtpSession.password = passOfSender
//        print("Gmailパスワード：",passOfSender)
//// 送信元のSMTPサーバーのpasword（Gmailパスワード）
//        smtpSession.port = 465
//        smtpSession.authType = MCOAuthType.saslPlain
//        smtpSession.connectionType = MCOConnectionType.TLS
//        smtpSession.connectionLogger = {(connectionID, type, data) in
//            if data != nil {
//                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
//                    print("Connectionloggerはこれ、",string)
//                }
//            }
//        }
//
//        let builder = MCOMessageBuilder()
//        builder.header.to = [MCOAddress(displayName: "西口さんへテスト", mailbox: uservalue[0])]
//        // 送信先の表示名とアドレス
//        builder.header.from = MCOAddress(displayName: "山田太郎2さんから", mailbox: mailOfSender)   // 送信元の表示名とアドレス
//        builder.header.subject = "Genchi Connect Me!"
////        builder.htmlBody = "Yo Rool, this is a test message!"
//        builder.textBody = "私のIDは[\(String(describing: peeridValue))]です。こちらはsendEmail()、signUpViewcontrollerによる送信です。\nhttps://genchi.net/y.html?key=\(String(describing: peeridValue))"
//        let rfc822Data = builder.data()
//        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
//        sendOperation?.start { (error) -> Void in
//            if error != nil {
//                print("メールの送信に失敗しました！")
//            } else {
//                print("メールの送信が成功しました！")
//
//            }
//        }
//    }
    
    
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
