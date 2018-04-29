//
//  AppDelegate.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 12/6/17.
//  Copyright © 2017 Nicholas Setliff. All rights reserved.
//

import UIKit
import Firebase


/// A set of methods that are called by the singleton UIApplication object in response to important events in the lifetime of your app.
/// The app delegate works alongside the app object to ensure your app interacts properly with the system and with other apps. Specifically, the methods of the app delegate give you a chance to respond to important changes. For example, you use the methods of the app delegate to respond to state transitions, such as when your app moves from foreground to background execution, and to respond to incoming notifications. In many cases, the methods of the app delegate are the only way to receive these important notifications.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    /// The backdrop for your app’s user interface and the object that dispatches events to your views.
    var window: UIWindow?
    
    /// Method called after the application has launched. Do any high-level setup within this method.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        UINavigationBar.appearance().barStyle = .blackOpaque

        let arView = window?.rootViewController?.childViewControllers[0].view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        SideMenuManager.default.menuLeftNavigationController = storyboard.instantiateViewController(withIdentifier:
                "SideMenuNavigationController") as? UISideMenuNavigationController
        
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: arView!, forMenu: UIRectEdge.left)

        return true
    }

    /// Method called when the application is about to move from active to inactive state. This can occure for certain types of temporary interruptions or when the user quits the application and it begins the transition to the background state.
    /// Use this method to puase ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    /// Method called to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    /// Method called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    // Method to restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    // Method called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}

