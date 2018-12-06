//
//  constants.swift
//  Blockstart
//
//  Created by Nathan Brewer on 6/24/18.
//  Copyright © 2018 Devslopes. All rights reserved.
//

import UIKit

struct MeteorFonts {
    static let fontBold = "SourceSansPro-Bold"
    static let fontRegular = "SourceSansPro-Regular"
    static let fontLight = "SourceSansPro-Light"
    static let fontItalic = "SourceSansPro-Italic"
}

struct WalletHomeStrings {
    static let scanWallet = "Scan to Import Wallet".localized
    static let myWallets = "My Mosaics".localized
    static let xemPrice = "Current XEM Price".localized
    static let newWallet = "New Wallet".localized
    static let importWallet = "Import From QR Code".localized
    static let importFromPK = "Import From Private Key".localized
    static let createNewWallet = "Create New Wallet".localized
}

struct CurrencyStrings {
    static let USD = "USD".localized
}

struct ViewControllerID {
    static let walletHomeVC = "WalletHomeVC"
    static let rootVC = "RootVC"
    static let sendHomeVC = "SendHomeVC"
    static let sendAmountVC = "SendAmountVC"
    static let sendConfirmationVC = "SendConfirmationVC"
    static let transactionDetailVC = "TransactionDetails"
    static let currencyDetailsVC = "CurrencyDetails"
    static let newWalletVC = "NewWalletVC"
    static let emailSentVC = "EmailSentVC"
    static let importWalletVC = "ImportWalletVC"
    static let settingSelectionVC = "SettingSelectionVC"
    static let backupWalletVC = "BackupWalletVC"
    static let pinVC = "PinVC"
}

struct Segues {
    static let toCreateWalletVC = "ToCreateWalletVC"
    static let toBackupWalletVC = "ToBackupWalletVC"
    static let unwindFromRequest = "unwindFromRequest"
    static let settingsContainer = "EmbeddedSettingsTable"
}

struct CellIdentifier {
    static let walletMosaicCell = "MosaicCell"
    static let walletDetailCell = "MosaicDetails"
    static let sendMosaicCell = "SendMosaicCell"
    static let receiveMosaicCell = "ReceiveMosaicCell"
    static let walletCell = "WalletCell"
    static let settingCell = "SettingsCell"
    static let pinCell = "PinCell"
}

struct CellHeight {
    static let sendMosaicCell = CGFloat(50)
    static let walletDetailCell = CGFloat(70)
    static let walletMosaicCell = CGFloat(70)
}

struct UserDefaultKeys {
    static let deepLinkAddress = "DeepLinkAddress"
    static let deepLinkAmount = "DeepLinkAmount"
    static let deepLinkMosaic = "DeepLinkMosaic"
    static let mainNetActive = "mainNetActive"
}

struct AlertMessage {
    static let passwordMismatch = "Passwords do not match".localized
    static let passwordLengthCheck = "Password must be at least 8 characters".localized
    static let completeForm = "Please fill out form completely".localized
    static let emailNotSent = "Email was not sent, please try again".localized
    static let noWallet = "Unable to find wallet".localized
    static let createNewWallet = "Make sure you have a wallet on your device, or you can create a new one from the home screen".localized
    static let notAuthorized = "Not Authorized".localized
    static let cameraAccess = "You can allow Meteor Wallet to access the camera in your phones Settings Menu".localized
    static let insufficientFunds = "Insufficient funds".localized
    static let missingMosaic = "Missing Mosaic".localized
    static let wrongPassword = "wrong password"
    static let incorrectPwdEntered = "Incorrect password".localized
    static let badQRCode = "bad QR".localized
    static let scanProperQRCode = "properQRCode".localized
    static let noStoredWallets = "No Wallets".localized
    static let noWalletNotice1 = "noWallet1".localized
    static let noWalletNotice2 = "noWallet2".localized
    static let wrongNetwork = "wrongNetwork".localized
    static let incorrectNetwork = "incorrectNetwork".localized
    static let duplicateImport = "duplicateImport".localized
    static let duplicateTitle = "duplicateTitle".localized
    static let noPhotoPermission = "noPhotoPermission".localized
    static let pinLockEnabled = "pinEnabled".localized
    static let pinLockDisabled = "pinDisabled".localized
}

struct AnimationJson {
    static let nemMoon = "nem-to-the-moon"
    static let checkmarkGreen = "checkmark-green"
}

struct WalletCreation {
    static let enterWalletAndPwd = "Enter a wallet account name and password".localized
    static let newWalletBoldText = ["account".localized, "name".localized, "password".localized]
    static let backupWalletHeader = "Meteor Wallet is fully decentralized and data is only stored locally.".localized
    static let backupWalletBoldText = ["data is only stored locally.".localized]
    static let importWalletHeader = "Enter the private key, wallet name, and password for your wallet".localized
    static let importWalletHeaderBold = ["private key".localized, "wallet name".localized, "password".localized]
    static let walletName = "wallet account name".localized
    static let sendBackupFile = "Send me my backup file".localized
    static let typeEmail = "Type email".localized
    static let privateKey = "private key".localized
    static let newWalletName = "wallet name".localized
    static let existingPassword = "password belonging to this wallet".localized
    static let importText = "Import".localized
    static let createWallet = "Create Wallet".localized
    static let photoBackup = "photoBackup".localized
    static let photosApp = "photos".localized
}

struct EmailMessage {
    static let emailSubject = "Your Wallet Backup".localized
    static let emailSentAddress = "An email has been sent to".localized
    static let emailFeedbackSubject = "Meteor Wallet Feedback"
    static let emailFeedback = "mark@blockstart.io"
    static let noEmailFound = "noEmailFound".localized
}

struct NetworkTypeStrings {
    static let main = "MAIN_NET"
    static let test = "TEST_NET"
}

struct TransactionStrings {
    static let received = "Received".localized
    static let sent = "Sent".localized
}

struct ExternalUrls {
    static let testNet = "http://bob.nem.ninja:8765/#/transfer/"
    static let mainNet = "http://explorer.nemchina.com/#/s_tx?hash="
    static let cryptoCompare = "https://www.cryptocompare.com"
}

struct XibStrings {
    static let privateKeyModal = "PrivateKeyModal"
    static let pinDisplay = "PinDisplay"
    static let pinPadDisplay = "PinPadDisplay"
}

struct AuthStrings {
    static let faceId = "faceId".localized
    static let touchId = "touchId".localized
    static let enablePin = "enablePin".localized
    static let disablePin = "disablePin".localized
    static let enablePinWarning = "enablePinWarning".localized
}

struct PinStateStrings {
    static let setPinTitle = "Enter New Pin".localized
    static let confirmPinTitle = "Confirm New Pin".localized
    static let accessPinTitle = "Enter Pin".localized
    static let removePinTitle = "removePinLock".localized
}

//General
let ADDRESS_COPIED = "Address Copied!".localized
let SMS_BODY = "Just a friendly reminder".localized
let SHOW = "Show".localized
let XEM = "XEM"
let MAIN = "Main"
let NEXT = "Next".localized
let SEND = "Send".localized
let CANCEL = "Cancel".localized
let SCHEME = "meteor-wallet"
let HOST = "request"
let PATH = "/address"
let RECIPIENT = "recipient".localized
let CURRENCY = "currency".localized
let AMOUNT = "amount".localized
let ERROR = "Error".localized
let PASSWORD = "password".localized
let DATA = "data"
let WALLET_NAME = "name"
let NAME = "name".localized
let PASSWORD_PLACEHOLDER = "Enter your password".localized
let RETYPE_PASSWORD = "Retype password".localized
let NO_CURRENCY_IN_WALLET = "You don't have any mosaics in this wallet".localized
let COPIED = "Copied!".localized
