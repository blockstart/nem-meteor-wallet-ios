//
//  VitalsService.swift
//  Meteor
//
//  Created by Jacob Luetzow on 9/5/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import Alamofire

class VitalsService: NSObject {
    static let instance = VitalsService()
    private weak var timer: Timer?
    private var nis: NIS?
    private var isStarting = false
    
    func startVitalMonitor() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.checkHeartbeat(onComplete: { (data) in
                guard let isConnected = data as? Bool else { return }
                if !isConnected && !self.isStarting && self.nis == nil {
                    self.nis = NIS()
                    self.isStarting = true
                    debugPrint("API Starting...")
                } else if isConnected && self.isStarting {
                    SocketService.instance.openConnection()
                    self.isStarting = false
                    debugPrint("Socket Starting...")
                }
            })
        })
    }
    
    private func checkHeartbeat(onComplete: @escaping Snapshot) {
        Alamofire.request("\(NISAPI.URL_BASE)\(NISAPI.URL_VITALS_HEARTBEAT)").responseJSON { response in
            onComplete(response.response?.statusCode == 200)
        }
    }
}
