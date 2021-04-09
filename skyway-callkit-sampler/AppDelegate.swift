//
//  ViewController.swift
//  skyway-callkit-sampler
//
//  Created by hyoi on 2021/01/21.
//  Copyright © 2021 hyoi. All rights reserved.
//


import UIKit
import PushKit
import UserNotifications
import SkyWay
import OneSignal
import SocketIO

var deviceStatus: String?
var deviceToken: String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let skywayAPIKey = "bc3292a3-35bd-4289-ac50-359c8100377c"
    let skywayDomain = "p2p-video-chat.app"

    let manager = SocketManager(socketURL: URL(string:"https://skyway-voip.herokuapp.com/:3000")!, config: [.log(true), .compress])
    var socket : SocketIOClient!

    //Callkit
    let callCenter = CallCenter(supportsVideo: true)

    var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    var timer: Timer?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunchKey"
        let firstlunch = [firstLunchKey:true]
        userDefaults.register(defaults: firstlunch)
        
        
        
        
        setupPushKit()
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("1308fc8f-2338-4f2e-92ec-a52bde4dbf1c")
        OneSignal.promptForPushNotifications(userResponse: { accepted in
              print("User accepted notifications: \(accepted)")
           })
        
        socket = manager.defaultSocket

                socket.on(clientEvent: .connect){ data, ack in
                    print("socket connected!")
                }

                socket.on(clientEvent: .disconnect){data, ack in
                    print("socket disconnected!")
                }

                socket.connect()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
            if error != nil {
                // エラー時の処理

                return
            }
            if granted {
                // デバイストークンの要求
                DispatchQueue.main.async(execute: {
                  UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //stopBackgroundTask()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if deviceStatus == "background"{
            deviceStatus = "RESET"
            print("deviceStatusをRESETにしました2")
        } else {
            print("アプリ終了")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try! encoder.encode(deviceToken)

            let jsonToken:String = String(data: data, encoding: .utf8)!

            socket.emit("Terminate", "",jsonToken)
            print("アプリが終了したことをonesignalへ送信しました")
            
            UserDefaults.standard.removeObject(forKey: "peerID")
            print("userDefaultを削除しました")
        }
    }


}

extension AppDelegate {
    func setupPushKit() {
        print("test: setupPushKit()")
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: .main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("test: didUpdate pushCredentials")
        let pkid = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
               print("deviceTokenは: \(pkid)")
        token = pkid
        deviceToken = pkid
        
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("test: didInvalidatePushTokenFor")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("test: didReceiveIncomingPushWith")
        self.callCenter.IncomingCall(true)
    }
}
