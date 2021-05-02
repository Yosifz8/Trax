//
//  AppDelegate.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 26/04/2021.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navVC = UINavigationController(rootViewController: ProductListVC())
        
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()

        return true
    }

}

