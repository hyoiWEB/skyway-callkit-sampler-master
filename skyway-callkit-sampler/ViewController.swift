//
//  ViewController.swift
//  skyway-callkit-sampler
//
//  Created by hyoi on 2021/01/21.
//  Copyright © 2021 hyoi. All rights reserved.
//

import UIKit
import CallKit
import SkyWay
import AVFoundation
import OneSignal
import SocketIO

var token: String?
var peeridValue:Array<String>=[]

//OneSignal
class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request;
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
}


class ViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate var peer: SKWPeer?
    fileprivate var dataConnection: SKWDataConnection?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?
    var gmailaddress:String?=UserDefaults.standard.string(forKey: "usedMailAddress")
    var mailboxValue:String?="gmail.com"
//    var gmailaddress2:String=uservalue[0]
//    var gmailpass:String=uservalue[1]
    let mailOfSender:String="usingfordevelop@gmail.com"
    let passOfSender:String="*umiush1"
    let userDefaults = UserDefaults.standard

    //@IBOutlet weak var myPeerIdLabel: UILabel!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var remoteStreamView: SKWVideo!
    //@IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
//    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    
    func sendEmailEX() {
        
        //メールアドレスの更新を確認します。更新されていたらuserValueを参照、されていなければuserDefaultを参照します。
        //意図しないタイミングでuserDefaultにアクセスするとメモリ不正エラーを起こしてしまうようです
        if updateJudge==true{
                mailboxValue=uservalue[0]
            }else{
                mailboxValue=gmailaddress
        }
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = mailOfSender
        print("Gmailアドレス：",mailOfSender)
        // 送信元のSMTPサーバーのusername（Gmailアドレス）
        smtpSession.password = passOfSender
        print("Gmailパスワード：",passOfSender)
        // 送信元のSMTPサーバーのpasword（Gmailパスワード）
        smtpSession.port = 465
        print("session.port465")
        smtpSession.authType = MCOAuthType.saslPlain
        print("session.authType")
        smtpSession.connectionType = MCOConnectionType.TLS
        print("connectionType.TLS")
//        print("ここまでの情報",uservalue[0],gmailaddress,mailOfSender,peeridValue)
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    print("Connectionloggerはこれ、",string)
                }
            }
        }

        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "西口さんへテスト", mailbox: mailboxValue)]
        // 送信先の表示名とアドレス
        builder.header.from = MCOAddress(displayName: "山田太郎2さんから", mailbox: mailOfSender)   // 送信元の表示名とアドレス
        builder.header.subject = "Genchi Connect Me!"
//        builder.htmlBody = "Yo Rool, this is a test message!"
        builder.textBody = "私のIDは[\(peeridValue[0])]です。\nhttps://genchi.net/y.html?key=\(peeridValue[0])"
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if error != nil {
                print("メールの送信に失敗しました！")
            } else {
                print("メールの送信が成功しました！")

            }
        }
    }
    
    
    @IBAction func toConnectionSettingsButton(_ sender: Any) {
//        performSegue(withIdentifier: toConnectionSettings, sender: self)
        mailSendConunt=false
    }
    
    
    //peerIDを格納
    var my_peerId: String?
    //オーディオスイッチ用
    var changeNo = 0
    //Callkitで応答したかどうかの確認用
    var AnswerCall = true
        
    let manager = SocketManager(socketURL: URL(string:"https://skyway-voip.herokuapp.com/:3000")!, config: [.log(true), .compress])
    var socket : SocketIOClient!

    //Callkit
    let callCenter = CallCenter(supportsVideo: true)

    //タイマーで実行される関数、peerIDとdeviceTokenを送信
    @objc func sendingss(){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        let peer = try! encoder.encode(my_peerId)
        let data = try! encoder.encode(token)
        let jsonPeer:String = String(data: peer, encoding: .utf8)!
        let jsonToken:String = String(data: data, encoding: .utf8)!
        socket.emit("Token", jsonPeer,jsonToken)
        print("タイマー実行中")
    }
    
    var mailSendConunt:Bool=false
    @objc func firstTimeMailSend(){
        print("firstTimeMailSend()が実行されたよ")
        if changelog==true{
            if mailSendConunt==false{
                changelog=false
                mailSendConunt=true
                sendEmailEX()
                print("無限ループしてるかも",mailSendConunt)
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //タイマー
        var timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendingss), userInfo: nil, repeats: false)
        
        
        var oneTimeTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(firstTimeMailSend), userInfo: nil, repeats: true)

        
        socket = manager.defaultSocket

                socket.on(clientEvent: .connect){ data, ack in
                    print("socket connected!")
                }

                socket.on(clientEvent: .disconnect){data, ack in
                    print("socket disconnected!")
                }

                socket.connect()
        
        // Do any additional setup after loading the view.
        //self.callButton.isEnabled = false
        self.endCallButton.isEnabled = false
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userDefaults.register(defaults: ["usedMailAddress":"まずは新しい接続先を編集してください！"])
       //初回起動をBoolで判定する
        let firstLunchKey = "firstLunchKey"
        if userDefaults.bool(forKey: firstLunchKey){
            performSegue(withIdentifier: "toSignIn", sender: self)
            userDefaults.set(false, forKey: firstLunchKey)
            userDefaults.synchronize()
        }
        if AppDelegate.shared.skywayAPIKey == nil || AppDelegate.shared.skywayDomain == nil {
            let alert = UIAlertController(title: "エラー", message: "APIKEYとDOMAINがAppDelegateに設定されていません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.mediaConnection?.close()
        self.peer?.destroy()
        //SocketHelper.shared.sendMessage(message: "繋がった！")
        checkPermissionAudio()
        callCenter.setup(self)
//        callCenter.setupNotifications()
        setup()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendEmailEX()
    }
    
    
    
    @IBAction func onSwitchCameraButtonClicked (_ sender:Any) {
        print("ボタンを押しました")
        if nil == localStream {
            return
        }
            print("リターンしました")

        var pos:SKWCameraPositionEnum = (localStream?.getCameraPosition())!
        print(pos,"宣言しました")

        if pos == SKWCameraPositionEnum.CAMERA_POSITION_BACK {
            pos = SKWCameraPositionEnum.CAMERA_POSITION_FRONT
            print(pos,"posが変わりました1")
        } else if pos == SKWCameraPositionEnum.CAMERA_POSITION_FRONT {
            pos = SKWCameraPositionEnum.CAMERA_POSITION_BACK
            print(pos,"posが変わりました2")
        } else {
            return
                print("なし")

        }
        localStream?.setCameraPosition(pos)
        print("全て変わりました2")
    }

    @IBAction func tapCall(){
        guard let peer = self.peer else {
            return
        }

        showPeersDialog(peer) { peerId in
            self.callCenter.StartCall(true)
            self.connect(targetPeerId: peerId)
        }
    }

    @IBAction func tapEndCall(){
        self.dataConnection?.close()
        self.mediaConnection?.close()
        self.changeConnectionStatusUI(connected: false)
        self.callCenter.EndCall()
    }

    func changeConnectionStatusUI(connected:Bool){
        if connected {
            //self.callButton.isEnabled = false
            self.endCallButton.isEnabled = true
        }else{
            //self.callButton.isEnabled = true
            self.endCallButton.isEnabled = false
        }
    }
    
    //スピーカーの切り替え
    @IBAction func tappedButton(_ sender: UIButton) {
        
            if changeNo == 0 {
                changeNo = 1
                //1回目に押した時に走らせたい処理
                remoteAudioDefault()
                let Speaker = UIImage(systemName: "earpods")
                speakerButton.setImage(Speaker, for: .normal)
                print("スピーカーOFF、イヤホンON")
                
            } else if changeNo == 1 {
                changeNo = 2
               
                //2回目に押した時に走らせたい処理
                remoteAudioOff()
                let Speaker = UIImage(systemName: "speaker.slash.fill")
                speakerButton.setImage(Speaker, for: .normal)
                print("ミュートON")
                
            } else if changeNo == 2 {
                changeNo = 0
                
                //3回目に押した時に走らせたい処理
                remoteAudioON()
                remoteAudioSpeaker()
                let Speaker = UIImage(systemName: "speaker.wave.2.fill")
                speakerButton.setImage(Speaker, for: .normal)
                print("スピーカーON、イヤホンOFF")
            }
        }
    }

// MARK: skyway

extension ViewController {

    func setup(){
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = AppDelegate.shared.skywayAPIKey
        option.domain = AppDelegate.shared.skywayDomain

        //userDefaultからpeerIDを読み込み
        let peerid = UserDefaults.standard.string(forKey: "peerID") ?? nil
        print("userDefaultsからpeerIDを読み込みました",peerid ?? "セットされていません")
        
        if peerid == nil {
            //ランダムなpeerIDを設定
            peer = SKWPeer(options: option)
            print("ランダムなpeerIDをセットしました")
        }else{
            //userDefaultsのpeerIDを設定
            peer = SKWPeer(id: peerid, options: option)
            
            print("前回更新されたpeerIDをセットしました")
            
        }
        
        
        if let _peer = peer {
            self.setupPeerCallBacks(peer: _peer)
            self.setupStream(peer: _peer)
        }else{
            let alert = UIAlertController(title: "エラー", message: "PeerのOpenに失敗しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func setupStream(peer:SKWPeer){
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        self.localStream = SKWNavigator.getUserMedia(constraints)
        self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
    }

    
    func call(targetPeerId:String){
        let option = SKWCallOption()
        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
    }

    func connect(targetPeerId:String){
        let options = SKWConnectOption()
        options.serialization = SKWSerializationEnum.SERIALIZATION_BINARY
        if let dataConnection = peer?.connect(withId: targetPeerId, options: options){
            self.dataConnection = dataConnection
            self.setupDataConnectionCallbacks(dataConnection: dataConnection)
        }else{
            print("failed to connect data connection")
        }
    }

    func showPeersDialog(_ peer: SKWPeer, handler: @escaping (String) -> Void) {
        peer.listAllPeers() { peers in
            if let peerIds = peers as? [String] {
                if peerIds.count <= 1 {
                    let alert = UIAlertController(title: "接続中のPeerId", message: "接続先がありません", preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                    alert.addAction(noAction)
                    self.present(alert, animated: true, completion: nil)

                }
                else {
                    let alert = UIAlertController(title: "接続中のPeerId", message: "接続先を選択してください", preferredStyle: .alert)
                    for peerId in peerIds{
                        if peerId != peer.identity {
                            let peerIdAction = UIAlertAction(title: peerId, style: .default, handler: { (alert) in
                                handler(peerId)
                            })
                            alert.addAction(peerIdAction)
                        }
                    }
                    let noAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                    alert.addAction(noAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: skyway callbacks

extension ViewController{

    func setupPeerCallBacks(peer:SKWPeer) {
        
        

        // MARK: PEER_EVENT_ERROR
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR) { obj in
            if let error = obj as? SKWPeerError {
                print("\(error)")
            }
        }

        // MARK: PEER_EVENT_OPEN
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN) { obj in
            if let peerId = obj as? String{
                DispatchQueue.main.async {
                    //self.myPeerIdLabel.text = peerId
                    self.changeConnectionStatusUI(connected: false)
                }
                print("your peerId: \(peerId)")
                
                //my_peerIdに格納
                self.my_peerId = peerId
                print("あなたのpeerIdは: \(self.my_peerId!)")
                peeridValue.insert(peerId, at: 0)
                print("代入後の値はこれ",peeridValue)

                //userDefaultsにpeerIDをセット
                UserDefaults.standard.set(peerId, forKey: "peerID")
                print("userDefaultsにpeerIDをセットしました")
                
                
                //peer.on時のメール送信
                if self.userDefaults.bool(forKey: "buttonCheck"){
                    self.sendEmailEX()
                }
                
                //OneSignalのデバイスTokenにpeerIdをタグ付け
//                OneSignal.sendTag("PeerID", value: peerId)
//                print("Tagを付与しました")
            }
        }

        // MARK: PEER_EVENT_CALL
            peer.on(SKWPeerEventEnum.PEER_EVENT_CALL) { obj in
                if self.AnswerCall == true {
                    if let connection = obj as? SKWMediaConnection{
                        self.setupMediaConnectionCallbacks(mediaConnection: connection)
                        self.mediaConnection = connection
                        connection.answer(self.localStream)
                        
                        self.AnswerCall = false
                    }
                } else {
                    print("通話中です",self.AnswerCall)
                }
                
            }

        // MARK: PEER_EVENT_CONNECTION
            peer.on(SKWPeerEventEnum.PEER_EVENT_CONNECTION) { obj in
                    if let connection = obj as? SKWDataConnection{
                        if self.dataConnection == nil {
                            //call画面を出す
                            self.callCenter.IncomingCall(true)
                        }
                        self.dataConnection = connection
                        self.setupDataConnectionCallbacks(dataConnection: connection)
                        
                        self.AnswerCall = false
                    }
            }
    }

    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){

        
        // MARK: MEDIACONNECTION_EVENT_STREAM
            mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM) { obj in
                if let msStream = obj as? SKWMediaStream{
                    self.remoteStream = msStream
                    DispatchQueue.main.async {
                        self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                    }
                    self.changeConnectionStatusUI(connected: true)
                    self.callCenter.Connected()
                    
                }
            }

        // MARK: MEDIACONNECTION_EVENT_CLOSE
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE) { obj in
            if let _ = obj as? SKWMediaConnection{
                DispatchQueue.main.async {
                    self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                    self.remoteStream = nil
                    self.dataConnection = nil
                    self.mediaConnection = nil
                }
                self.changeConnectionStatusUI(connected: false)
                self.callCenter.EndCall()
                
                //ブラウザ側が切った時
                //callkitで切った時
                self.AnswerCall = true
                print("trueになりました",self.AnswerCall)
                
                //self.newPeer()
            }
        }
        
    }

    func setupDataConnectionCallbacks(dataConnection:SKWDataConnection){
        // MARK: DATACONNECTION_EVENT_OPEN
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_OPEN) { obj in
            self.changeConnectionStatusUI(connected: true)
            
        }

        // MARK: DATACONNECTION_EVENT_CLOSE
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_CLOSE) { obj in
            print("close data connection")
            self.dataConnection = nil
            self.changeConnectionStatusUI(connected: false)
            self.callCenter.EndCall()
            
        }
    }
}

// MARK: CXProviderDelegate

extension ViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {

    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        callCenter.ConfigureAudioSession()
        callCenter.Connecting()
        action.fulfill()
    }

    //Callkitで応答を選択した時の動作
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        callCenter.ConfigureAudioSession()
        if let peer = self.dataConnection?.peer {
            self.call(targetPeerId: peer)
        }
        action.fulfill()
        
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        self.dataConnection?.close()
        self.mediaConnection?.close()
        action.fulfill()
        
        //callkitで切った時
        //ブラウザ側が切った時
        self.AnswerCall = true
        print("trueになりました",self.AnswerCall)
    }
}

// MARK: オーディオ設定
extension ViewController {
    func checkPermissionAudio() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .denied:
            let alert = UIAlertController(title: "マイクの許可", message: "アプリの設定画面からマイクの使用を許可してください", preferredStyle: .alert)
            let settings = UIAlertAction(title: "設定を開く", style: .default) { result in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            alert.addAction(settings)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { result in
                print("getAudioPermission: \(result)")
            }
        case .restricted:
            let alert = UIAlertController(title:nil, message: "マイクの使用が制限されています（通話することができません）", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
}

extension ViewController {
    
    // サウンドの停止はオーディオトラックを無効にすることで実装
    func remoteAudioOff() {
      self.remoteStream?.setEnableAudioTrack(0, enable: false)
    }
    
    func remoteAudioON() {
      self.remoteStream?.setEnableAudioTrack(0, enable: true)
    }
    
    // デフォルト（ヘッドホン出力）の場合
    func remoteAudioDefault() {
      self.remoteStream?.setEnableAudioTrack(0, enable: false)
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        // headphone
        do {
          try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
          self.remoteStream?.setEnableAudioTrack(0, enable: true)
        } catch {
          print("AVAudioSessionCategoryPlayAndRecord error")
        }
      }
    }
     
    // スピーカー出力の場合
    func remoteAudioSpeaker() {
      self.remoteStream?.setEnableAudioTrack(0, enable: false)
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        // speaker
        do {
          try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
          self.remoteStream?.setEnableAudioTrack(0, enable: true)
        } catch {
          print("AVAudioSessionCategoryPlayAndRecord error")
        }
      }
    }
}

