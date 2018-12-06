//
//  TimeWindowNIS1.swift
//  Meteor
//
//  Created by Jacob Luetzow on 8/31/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

#if NIS1
import Foundation

extension TimeWindow: NIS1 {
    typealias NIS1JSON = TimeWindowJSON
    typealias JSONModel = TimeWindow
    
    static func fromNIS1JSON(json: TimeWindowJSON) -> TimeWindow {
        var timeWindow = TimeWindow()
        timeWindow.deadline = json.deadline ?? ""
        timeWindow.timeStamp = json.timeStamp ?? ""
        return timeWindow
    }
}
#endif
