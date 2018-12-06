//
//  EmailManager.swift
//  Blockstart
//
//  Created by Nathan Brewer on 7/5/18.
//  Copyright © 2018 Blockstart. All rights reserved.
//

import UIKit
import MessageUI

class EmailManager: NSObject {
    var messageWindow: UIWindow?
    var delegate: MFMailComposeViewControllerDelegate?
    var subject: String?
    var body: String?
    var recipients: [String]?
    var emailController: MFMailComposeViewController?
    var attachmentData: Data?
    
    var canCompose: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func recipients(_ sendTo: [String]) -> EmailManager {
        self.recipients = sendTo
        return self
    }
    
    func body(_ emailBody: String) -> EmailManager {
        self.body = emailBody
        return self
    }
    
    func subject(_ title: String) -> EmailManager {
        self.subject = title
        return self
    }
    
    func build() -> UIViewController? {
        guard canCompose else {
            return nil
        }
        emailController = MFMailComposeViewController()
        emailController?.mailComposeDelegate = delegate ?? self
        if let body = self.body, let recip = self.recipients, let sub = self.subject {
            if let att = self.attachmentData {
                emailController?.addAttachmentData(att, mimeType: "image/jpg", fileName: "Image")
            }
            emailController?.setMessageBody(body, isHTML: false)
            emailController?.setToRecipients(recip)
            emailController?.setSubject(sub)
            return emailController
        }
        return nil
        
    }
    
    func show() {
        messageWindow = UIWindow(frame: UIScreen.main.bounds)
        messageWindow?.rootViewController = UIViewController()
        let topWindow = UIApplication.shared.windows.last
        messageWindow?.windowLevel = (topWindow?.windowLevel ?? UIWindow.Level(0)) + 1
        messageWindow?.makeKeyAndVisible()
        if let messageController = build() {
            messageWindow?.rootViewController?.present(messageController, animated: true, completion: nil)
        }
    }
    
    func hide() {
        emailController?.dismiss(animated: true, completion: nil)
        emailController = nil
        messageWindow?.isHidden = true
        messageWindow = nil
    }
}

extension EmailManager: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        hide()
    }
}
