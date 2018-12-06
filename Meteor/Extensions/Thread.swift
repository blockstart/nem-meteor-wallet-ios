//
//  Thread.swift
//  Blockstart
//
//  Created by Mark Price on 7/25/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import Foundation

extension Thread {
    class func createWithTarget(target: Any, selector: Selector, object: Any?, stackSize: Int) -> Thread? {
        guard ((stackSize % 4096) == 0) else {
            return nil
        }
        let thread = Thread(target: target, selector: selector, object: object)
        thread.stackSize = stackSize
        return thread
    }
}
