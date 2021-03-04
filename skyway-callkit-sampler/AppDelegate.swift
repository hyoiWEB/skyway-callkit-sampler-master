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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let skywayAPIKey = "bc3292a3-35bd-4289-ac50-359c8100377c"
    let skywayDomain = "p2p-video-chat.app"

    //Callkit
    let callCenter = CallCenter(supportsVideo: true)

    var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    var timer: Timer?
    
    var deviceToken: String?

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupPushKit()
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("253ebb23-922e-4e29-b0af-0a0f8796dfeb")
        OneSignal.promptForPushNotifications(userResponse: { accepted in
              print("User accepted notifications: \(accepted)")
           })
        
        
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
        OneSignal.setExternalUserId(pkid)
        print("ExternalIDを付与しました")
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
