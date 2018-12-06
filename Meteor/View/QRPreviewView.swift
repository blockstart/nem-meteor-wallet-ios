//
//  QRPreviewView.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/16/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit
import AVFoundation

class QRPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
