//
//  NotificationService.swift
//  Meteor
//
//  Created by Nathan Brewer on 8/21/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import UserNotifications

struct NotificationStrings {
    static let unconfirmedId = "unconfirmedId"
    static let unconfirmedTitle = "Pending".localized
    static let unconfirmedThreadID = "unconfirmedThreadId"
    static let confirmedId = "confirmedId"
    static let confirmedTitle = "Received".localized
    static let confirmedThreadId = "confirmedThreadId"
    static let categoryId = "categoryId"
}

class NotificationService {
    static let instance = NotificationService()
    
    private func createNotification(title: String, body: String, id: String, thread: String) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            if settings.alertSetting == .enabled {
                let content = UNMutableNotificationContent()
                content.title = title
                content.subtitle = ""
                content.body = body
                content.threadIdentifier = thread
                content.categoryIdentifier = NotificationStrings.categoryId
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber += 1
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    if error != nil {
                        debugPrint(error as Any)
                    }
                }
            }
        }
    }
    
    func unconfirmedTransaction(_ transaction: TransactionNotif) {
        if transaction.senderAddress == AppState.fromCache().selectedAddress {
            return
        } else if transaction.recipientAddress == AppState.fromCache().selectedAddress {
            let mosaicName = transaction.mosaicName
            createNotification(title: NotificationStrings.unconfirmedTitle + " " + mosaicName,
                               body: "From: \(transaction.senderAddress)",
                id: NotificationStrings.unconfirmedId,
                thread: NotificationStrings.unconfirmedThreadID)
        }
    }
    
    func confirmedTransaction(_ transaction: TransactionNotif) {
        if transaction.senderAddress == AppState.fromCache().selectedAddress {
            return
        } else if transaction.recipientAddress == AppState.fromCache().selectedAddress {
            let mosaicName = transaction.mosaicName
            createNotification(title: mosaicName + " " + NotificationStrings.confirmedTitle,
                               body: "From: \(transaction.senderAddress)",
                id: NotificationStrings.confirmedId,
                thread: NotificationStrings.confirmedThreadId)
        }
    }
        
}
