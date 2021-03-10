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


class ViewController: UIViewController {

    fileprivate var peer: SKWPeer?
    fileprivate var dataConnection: SKWDataConnection?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?

    //@IBOutlet weak var myPeerIdLabel: UILabel!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var remoteStreamView: SKWVideo!
    //@IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
//    @IBOutlet weak var muteButton: UIButton!
    
    
    var my_peerId: String?
    var token: String?
    
    
    //オーディオスイッチ用
//    var flag: Bool = false
    var changeNo = 0
    //ミュートスイッチ用
//    var Secondflag: Bool = false
    
    //Callkitで応答したかどうかの確認用
    var AnswerCall = 0
    
    //通話中か確認用のflag
    var flag = 0

    
    let manager = SocketManager(socketURL: URL(string:"http://192.168.22.43:3000/")!, config: [.log(true), .compress])
    var socket : SocketIOClient!

    
    //Callkit
    let callCenter = CallCenter(supportsVideo: true)
    
    
    //tokenにdeviceTokenを代入
    func loadRequest(for deviceTokenString : String){
        
        token = deviceTokenString
    }


    //タイマーで実行される関数
    @objc func sendingss(){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(token)
        let jsonstr:String = String(data: data, encoding: .utf8)!
        socket.emit("Token", jsonstr)
        print("タイマー実行中")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.viewController = self
        //タイマー
        var timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendingss), userInfo: nil, repeats: false)
        
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
        
        if AppDelegate.shared.skywayAPIKey == nil || AppDelegate.shared.skywayDomain == nil {
            let alert = UIAlertController(title: "エラー", message: "APIKEYとDOMAINがAppDelegateに設定されていません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }

        //SocketHelper.shared.sendMessage(message: "繋がった！")
        checkPermissionAudio()
        callCenter.setup(self)
//        callCenter.setupNotifications()
        setup()
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
    
//    //ミュートの切り替え
//    @IBAction func muteButton(_ sender: UIButton) {
//            if Secondflag == false {
//                //ONにした時に走らせたい処理
//                remoteAudioOff()
//                Secondflag = true
//                let muteSpeaker = UIImage(systemName: "speaker.slash.fill")
//                muteButton.setImage(muteSpeaker, for: .normal)
//                print("ミュートON")
//            } else if Secondflag == true {
//                //OFFにした時に走らせたい処理
//                remoteAudioON()
//                Secondflag = false
//                let muteSpeaker = UIImage(systemName: "speaker.fill")
//                muteButton.setImage(muteSpeaker, for: .normal)
//                print("ミュートOFF")
//            }
//        }
}

// MARK: skyway

extension ViewController {

    func setup(){
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = AppDelegate.shared.skywayAPIKey
        option.domain = AppDelegate.shared.skywayDomain

        //peer = SKWPeer(id: "maid-shokan", options: option)
        peer = SKWPeer(options: option)
        
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
                
                //OneSignalのデバイスTokenにpeerIdをタグ付け
                OneSignal.sendTag("PeerID", value: peerId)
                print("Tagを付与しました")
            }
        }

        // MARK: PEER_EVENT_CALL
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL) { obj in
            if let connection = obj as? SKWMediaConnection{
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.localStream)
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
            }
        }
    }

    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){

        if AnswerCall == 1 {
        // MARK: MEDIACONNECTION_EVENT_STREAM
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM) { obj in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                DispatchQueue.main.async {
                    self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                }
                self.changeConnectionStatusUI(connected: true)
                self.callCenter.Connected()
                self.flag = 1
                print("flagは",self.flag)
            }
        }
        }else{
            print("着信を拒否しています")
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
                self.flag = 0
                print("flagは",self.flag)
                self.AnswerCall = 0
                print("AnswerCall",self.AnswerCall)
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
        self.AnswerCall = 1
        print("AnswerCall",AnswerCall)
        
        callCenter.ConfigureAudioSession()
        if let peer = self.dataConnection?.peer {
            self.call(targetPeerId: peer)
        }
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        self.AnswerCall = 0
        print("AnswerCall",AnswerCall)
        
        self.dataConnection?.close()
        self.mediaConnection?.close()
        action.fulfill()
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

