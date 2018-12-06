//
//  PushNotification.swift
//  Meteor
//
//  Created by Jacob Luetzow on 9/18/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import Foundation
import Alamofire

struct PushNotification: Serializable {
    var addressValue = ""
    var deviceId = ""
    let platformType = "ios"
}

struct PushAPI {
    static let URL_REGISTER = "https://your-push-notif-test-server.io/staging/v1/pushNotification/register"
    static let URL_MAIN_REGISTER = "https://your-push-notif-server.io/v1/pushNotification/register"
}

extension PushNotification {
    static func register(pushNotification: PushNotification, onComplete: @escaping Snapshot, onError: Snapshot? = nil) {
        let url = AppState.fromCache().currentNetwork == NetworkTypeStrings.main
            ? PushAPI.URL_MAIN_REGISTER
            : PushAPI.URL_REGISTER
        let data = pushNotification.serialize()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        Alamofire.request(request)
            .responseJSON { (_) in
            onComplete(true)
        }
    }
}
