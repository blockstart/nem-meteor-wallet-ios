//
//  QRCodeScanner.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/16/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate var captureSession = AVCaptureSession()
    fileprivate(set) var videoPreview = QRPreviewView()
    let screenSize = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    var delegate: QRScanner?
    
    override init() {}
    
    func checkCameraPermissions(completion: @escaping (Bool) -> ()) {
        let auth = AVCaptureDevice.authorizationStatus(for: .video)
        switch auth {
        case .authorized:
            completion(true)
        case .denied:
            delegate?.accessDenied()
        case .restricted:
            delegate?.accessDenied()
        default:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    completion(true)
                } else { return }
            }
        }
    }
    
    func prepareCaptureSession(_ padding: CGFloat) {
        let centerScreen = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let metaData = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metaData) else { return }
            captureSession.addOutput(metaData)
            captureSession.commitConfiguration()
            metaData.setMetadataObjectsDelegate(self, queue: .main)
            metaData.metadataObjectTypes = [.qr]
            videoPreview = QRPreviewView()
            if let overlay = UIImage(named: "qr_scanner_overlay") {
                let overlayView = UIImageView(image: overlay)
                videoPreview.addSubview(overlayView)
                videoPreview.addSubview(cancelScanBtn(padding))
                overlayView.contentMode = .scaleAspectFit
                overlayView.center.x = centerScreen.x
                overlayView.center.y = centerScreen.y - overlayView.center.y
            }
            videoPreview.videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreview.videoPreviewLayer.session = captureSession
            captureSession.startRunning()
        } catch { return }
    }
    
    func cancelScanBtn(_ extraPadding: CGFloat) -> UIButton {
        let buttonPadding: CGFloat = 60
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width - buttonPadding, height: 50))
        button.center.x = screenSize.width / 2
        button.center.y = screenSize.height - extraPadding
        button.setTitle(CANCEL, for: .normal)
        button.titleLabel?.font = UIFont(name: MeteorFonts.fontBold, size: 17)
        button.backgroundColor = BSColor.fadedBlack
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(cancelSession), for: .touchUpInside)
        return button
    }
    
    @objc func cancelSession() {
        delegate?.cancelSession()
    }
    
    func animateFadeInOut(_ show: Bool, views: [UIView]) {
        UIView.animate(withDuration: 0.3) {
            for v in views {
                v.alpha = show ? 1 : 0
            }
        }
    }
    
    func generateQRCode(from data: Dictionary<String, AnyObject>) -> UIImage? {
        do {
            let dataObj = try JSONSerialization.data(withJSONObject: data, options: .init(rawValue: 0))
            return createQRImage(with: dataObj as NSData)
        } catch { return nil }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        return createQRImage(with: data as NSData)
    }
    
    fileprivate func createQRImage(with data: NSData) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 6, y: 6)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        let img = convert(ciImage: output)
        return img
    }
    
    fileprivate func convert(ciImage: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let validCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = validCode.stringValue else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        captureSession.stopRunning()
        delegate?.scanResult(result: code)
    }
}
