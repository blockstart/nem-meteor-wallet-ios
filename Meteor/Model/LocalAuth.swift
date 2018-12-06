//
//  LocalAuth.swift
//  Meteor
//
//  Created by Nathan Brewer on 10/13/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation
import Cache

struct LocalAuth: Codable {
    
    static fileprivate let STORAGE_KEY = "AuthServiceKey"
    internal(set) var privatePin: String
    internal(set) var pinLockEnabled: Bool
    
    static func storage() -> HybridStorage<LocalAuth>? {
        do {
            let memory = MemoryStorage<LocalAuth>(config: MemoryConfig())
            let disk = try DiskStorage<LocalAuth>(config: DiskConfig(name: "AuthenticatorDisk"), transformer: TransformerFactory.forCodable(ofType: LocalAuth.self))
            return HybridStorage(memoryStorage: memory, diskStorage: disk)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
            return nil
        }
    }
    
    func save() {
        do {
            try LocalAuth.storage()?.setObject(self, forKey: LocalAuth.STORAGE_KEY)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    func delete() {
        do {
            try LocalAuth.storage()?.removeObject(forKey: LocalAuth.STORAGE_KEY)
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
    }
    
    static func fromCache() -> LocalAuth {
        do {
            if let authService = try LocalAuth.storage()?.object(forKey: LocalAuth.STORAGE_KEY) {
                return authService
            }
        } catch {
            debugPrint("Error: ", error.localizedDescription)
        }
        return LocalAuth(privatePin: "", pinLockEnabled: false)
    }
}
