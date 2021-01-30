//
//  AppDelegate.swift
//  skyway-callkit-sampler
//
//  Created by yorifuji on 2019/08/06.
//  Copyright © 2019 yorifuji. All rights reserved.
//

import UIKit
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let skywayAPIKey = "bc3292a3-35bd-4289-ac50-359c8100377c"
    let skywayDomain = "p2p-video-chat.app"

    var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    var timer: Timer?
    

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupPushKit()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        startBackgroundTask()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        stopBackgroundTask()
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
    
    func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
            self.stopBackgroundTask()
        }
    }

    func stopBackgroundTask() {
        if backgroundTaskID != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}


extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print("test: didUpdate pushCredentials")
        let pkid = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("your device token: \(pkid)")
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("test: didInvalidatePushTokenFor")
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("test: didReceiveIncomingPushWith")
        //incomingCall()
    }
}
