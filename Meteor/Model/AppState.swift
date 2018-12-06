//
//  AppState.swift
//  Meteor
//
//  Created by Mark Price on 8/30/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import Foundation
import Cache
import UserNotifications

struct AppState: Codable {
    
    static let NOTIF_APP_STATE_UPDATED = Notification.Name(rawValue: "notif_app_state_updated")
    static let NOTIF_APP_STATE_DELETED = Notification.Name(rawValue: "notif_app_state_deleted")
    
    static fileprivate let STORAGE_KEY = "AppState"
    static fileprivate let DISK_KEY = "AppStateDisk"
    internal(set) var selectedAddress: String
    internal(set) var addresses: [String]
    internal(set) var deviceToken: String
    internal(set) var currentNetwork: String
    
    static func storage() -> HybridStorage<AppState>? {
        do {
            let memory = MemoryStorage<AppState>(config: MemoryConfig())
            let disk = try DiskStorage<AppState>(config: DiskConfig(name: AppState.DISK_KEY), transformer: TransformerFactory.forCodable(ofType: AppState.self))
            return HybridStorage(memoryStorage: memory, diskStorage: disk)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
            return nil
        }
    }
    
    func save(_ onOpen: Bool = false) {
        do {
            var newState = self
            let prevDeviceToken = AppState.fromCache().deviceToken
            if newState.deviceToken != prevDeviceToken && !onOpen {
                newState.deviceToken = prevDeviceToken
            }
            try AppState.storage()?.setObject(newState, forKey: AppState.STORAGE_KEY)
            NotificationCenter.default.post(Notification(name: AppState.NOTIF_APP_STATE_UPDATED))
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                let appState = AppState.fromCache()
                if appState.selectedAddress != "" || appState.deviceToken != "" {
                    let push = PushNotification.init(addressValue: appState.selectedAddress, deviceId: appState.deviceToken)
                    PushNotification.register(pushNotification: push, onComplete: { (_) in
                        debugPrint("Notifications Registered to \(appState.deviceToken)")
                    })
                }
            }
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    func delete() {
        do {
            try AppState.storage()?.removeObject(forKey: AppState.STORAGE_KEY)
            NotificationCenter.default.post(Notification(name: AppState.NOTIF_APP_STATE_DELETED))
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    static func fromCache() -> AppState {
        do {
            if let account = try AppState.storage()?.object(forKey: AppState.STORAGE_KEY) {
                return account
            }
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
        return AppState(selectedAddress: "", addresses: [], deviceToken: "", currentNetwork: NetworkTypeStrings.main)
    }
    
    func switchNetwork(to network: String, address: String, onComplete: Snapshot? = nil) {
        var appState = AppState.fromCache()
        Account.switchNetwork(to: network, onComplete: { (_) in
            appState.selectedAddress = address
            appState.currentNetwork = network
            appState.save()
            onComplete?(true)
        }) { (err) in
            if let err = err as? APIError {
                debugPrint(err.message)
            }
        }
    }
}
