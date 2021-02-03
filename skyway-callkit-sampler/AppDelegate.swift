//
//  ViewController.swift
//  skyway-callkit-sampler
//
//  Created by hyoi on 2021/01/21.
//  Copyright © 2021 hyoi. All rights reserved.
//


import UIKit
import NCMB
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let skywayAPIKey = "bc3292a3-35bd-4289-ac50-359c8100377c"
    let skywayDomain = "p2p-video-chat.app"

    var backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    var timer: Timer?
    
    // NCMB APIキーの設定
    let applicationkey = "447e4b01fd3fc00cfddf795ad24ca807351edf5f82052fbc791818994f3b73a9"
    let clientkey      = "7f403becd92cef8bafd608fd5776036959a9834c285214fbe84c49ff7ae9cc11"

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // SDKの初期化
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)
        
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
    
    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation
        // デバイストークンの設定
        installation.setDeviceTokenFromData(data: deviceToken)
        // 端末情報をデータストアに登録
        installation.saveInBackground {result in
            switch result {
                case .success:
                    // 端末情報の登録に成功した時の処理
                    print("トークン取得")
                    break
            case let .failure(error):
                    // 端末情報の登録に失敗した時の処理
                    print(error)
                    break
            }
        }

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

//extension AppDelegate {
//
//    func startBackgroundTask() {
//        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
//        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
//            self.stopBackgroundTask()
//        }
//    }
//
//    func stopBackgroundTask() {
//        if backgroundTaskID != UIBackgroundTaskIdentifier.invalid {
//            UIApplication.shared.endBackgroundTask(backgroundTaskID)
//            backgroundTaskID = UIBackgroundTaskIdentifier.invalid
//        }
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//    }
//}
