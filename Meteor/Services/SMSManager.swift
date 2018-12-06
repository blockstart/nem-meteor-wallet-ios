//
//  SMSManager.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/27/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import MessageUI

class MessageBuilder: NSObject {
    var messageWindow: UIWindow?
    var body: String?
    var phoneNumber: String?
    var messageController: MFMessageComposeViewController?
    var homeVC = UIViewController()
    
    var canCompose: Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func body(_ body: String?) -> MessageBuilder {
        self.body = body
        return self
    }
    
    func phoneNumber(_ phone: String?) -> MessageBuilder {
        self.phoneNumber = phone
        return self
    }
    
    func build() -> UIViewController? {
        guard canCompose else {
            return nil
        }
        messageController = MFMessageComposeViewController()
        messageController?.body = body
        messageController?.recipients = nil
        messageController?.messageComposeDelegate = self
        return messageController
    }
    
    func show(_ currentVC: UIViewController) {
        homeVC = currentVC
        messageWindow = UIWindow(frame: UIScreen.main.bounds)
        messageWindow?.rootViewController = UIViewController()
        let topWindow = UIApplication.shared.windows.last
        messageWindow?.windowLevel = (topWindow?.windowLevel ?? 0) + 1
        messageWindow?.makeKeyAndVisible()
        if let messageController = build() {
            messageWindow?.rootViewController?.present(messageController, animated: true, completion: nil)
        }
    }
    
    func hide() {
        messageController?.dismiss(animated: true, completion: nil)
        messageController = nil
        messageWindow?.isHidden = true
        messageWindow = nil
    }
}

extension MessageBuilder: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        homeVC.view.endEditing(true)
        homeVC.performSegue(withIdentifier: Segues.unwindFromRequest, sender: nil)
        hide()
    }
}




