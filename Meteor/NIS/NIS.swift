//
//  NIS.swift
//  Meteor
//
//  Created by Mark Price on 7/25/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//
import Foundation

class NIS {    
    init() {
        #if NIS1
        if let apiThread = Thread.createWithTarget(target: self, selector: #selector(NIS.startNISAPI), object: nil, stackSize: 1024*1024) {
            apiThread.start()
        }
        #endif
    }
    
    #if NIS1
    @objc func startNISAPI() {
        guard let srcPath = Bundle.main.path(forResource: "node/bundle.js", ofType: "") else {
            return assert(false, "Must include nem-nis1-mobile-wrapper in project")
        }
        let args: [Any] = ["node", srcPath]
        NodeRunner.startEngine(withArguments: args)
    }
    #endif
}
