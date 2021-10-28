//
//  AppDelegate.swift
//  Networking
//
//  Created by Alexey Efimov on 25/07/2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Это мы копируем с сайта FB
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
          
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        FirebaseApp.configure()

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Используется для захвата текущего id сессии
    var bgSessionCompletionHandler: (() -> ())?

    // Этот метод вызывается при завершении всех Backgroun загрузок
    /// Что бы сохранить захваченое значение из completionHandler мы должны создать отдельное свойство. В него будет передаваться сообщение с id сессии. При запуске приложения автоматически создается BG сессия, которая связвается с текущей BG сессией
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        bgSessionCompletionHandler =  completionHandler
    }
}

