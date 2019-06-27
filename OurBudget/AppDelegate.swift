//
//  AppDelegate.swift
//  OurBudget
//
//  Created by Anton Bredykhin on 6/10/19.
//  Copyright © 2019 Anton Bredykhin. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseUI
import LinkKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        PLKPlaidLink.setup { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }

        FirebaseApp.configure()
        setupFCM(application: application)
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
}

extension AppDelegate {
    private func setupFCM(application: UIApplication) {
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict: [String: String] = [Constants.FCM.token: fcmToken]
        NotificationCenter.default.post(name: Notification.Name(Constants.FCM.receivedToken), object: nil, userInfo: dataDict)

        Messaging.messaging().subscribe(toTopic: Constants.FCM.Topic.balance) { error in
            if error != nil {
                print("Unable to subscribe to balance topic: \(String(describing: error))")
            } else {
                print("Subscribed to balance topic")
            }
        }
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")

        let dataDict: [String: [AnyHashable: Any]] = [Constants.FCM.messageBody: remoteMessage.appData]
        NotificationCenter.default.post(name: Notification.Name(Constants.FCM.newMesssage), object: nil, userInfo: dataDict)
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // TODO: Handle data of notification
        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TODO: Handle data of notification
        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}
