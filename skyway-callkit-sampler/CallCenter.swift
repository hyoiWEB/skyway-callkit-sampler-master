//
//  ViewController.swift
//  skyway-callkit-sampler
//
//  Created by hyoi on 2021/01/21.
//  Copyright © 2021 hyoi. All rights reserved.
//


import Foundation
import AVFoundation
import CallKit

class CallCenter: NSObject {

    private let controller = CXCallController()
    private let provider: CXProvider
    private var uuid = UUID()
    

    init(supportsVideo: Bool) {
        let providerConfiguration = CXProviderConfiguration(localizedName: "SkyWay(CallKit)")
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = supportsVideo
        provider = CXProvider(configuration: providerConfiguration)
        //configuration.iconTemplateImageData = UIImage(named:"app_icon").pngData() // CallKitの通話UIに表示されるアプリへの導線ボタン画像

    }


    func setup(_ delegate: CXProviderDelegate) {
        provider.setDelegate(delegate, queue: nil)
    }

    func StartCall(_ hasVideo: Bool = false) {
        uuid = UUID()
        let handle = CXHandle(type: .generic, value: "株式会社〇〇")
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = hasVideo
        let transaction = CXTransaction(action: startCallAction)
        controller.request(transaction) { error in
            if let error = error {
                print("CXStartCallAction error: \(error.localizedDescription)")
            }
        }
    }

    func IncomingCall(_ hasVideo: Bool = false) {
        uuid = UUID()
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "株式会社〇〇")
        update.hasVideo = hasVideo
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("reportNewIncomingCall error: \(error.localizedDescription)")
            }
        }
    }

    func EndCall() {
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        controller.request(transaction) { error in
            if let error = error {
                print("CXEndCallAction error: \(error.localizedDescription)")
            }
        }
    }

    func Connecting() {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    func Connected() {
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }

    func ConfigureAudioSession() {
        // Setup AudioSession
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .voiceChat, options: [])
    }
}

// MARK: DEBUG

extension CallCenter {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMediaServerReset),
                                               name: AVAudioSession.mediaServicesWereResetNotification,
                                               object: nil)
    }

    @objc func handleRouteChange(notification: Notification) {
        print("handleRouteChange: \(notification)")
    }

    @objc func handleInterruption(notification: Notification) {
        print("handleInterruption: \(notification)")
    }

    @objc func handleMediaServerReset(notification: Notification) {
        print("handleMediaServerReset: \(notification)")
    }
}

