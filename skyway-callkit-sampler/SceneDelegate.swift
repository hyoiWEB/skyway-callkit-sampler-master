//
//  SceneDelegate.swift
//  skyway-callkit-sampler
//
//  Created by 三浦将太 on 2021/03/10.
//  Copyright © 2021 yorifuji. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("アプリがバックグラウンドから復帰しました")
        deviceStatus = "RESET"
        print("deviceStatusをRESETにしました")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("アプリがバックグラウンドに入りました")
        deviceStatus = "background"
        print("deviceStatusをbackgroundにしました")
    }


}

