//
//  DataExt.swift
//  Meteor
//
//  Created by Nathan Brewer on 9/10/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit

extension Data {
    func returnResult<Element: Codable>(_ decodableObj: Element.Type) -> Element? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(decodableObj, from: self)
            return result
        } catch {
            debugPrint("Error decoding JSON", error.localizedDescription)
        }
        return nil
    }
}
