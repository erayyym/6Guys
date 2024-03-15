//
//  AppEntry.swift
//  PocketLedger
//
//  Created by Chen Yang/Yang Gao on 3/15/24.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@main
class AppEntry:UIResponder, UIApplicationDelegate{
    var window: UIWindow?
    
    func application(_application: UIApplication, didFinishLaunchingWithOptions launchoption: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
        //UI window and color
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        self.window = window
        //mainview
        showMain()
        IQKeyboardManager.shared.enable = true

        window.makeKeyAndVisible()
        return true
    }
    
    func showMain(){
        window?.rootViewController=UINavigationController(rootViewController: MainViewController())
    }
}
