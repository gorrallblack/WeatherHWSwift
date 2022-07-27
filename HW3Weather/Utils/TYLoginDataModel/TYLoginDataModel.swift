//
//  TYLoginDataModel.swift
//  
//

import UIKit
import Foundation
import CommonCrypto

class TYLoginDataModel: NSObject, NSCoding {
    var username : NSString!
    var key : NSString!
    
    var isLogoutFromApp : Bool!
    var valid : Bool = false
    
    
    static var TYUserAuthSucceededNotification: String = "TYUserAuthSucceededNotification"
    static var TYUserAuthFailedNotification: String = "TYUserAuthFailedNotification"
    static var kSavedLoginDataModelKey: String = "SavedLoginDataModel"
    static var sharedLoginDataModelObj : TYLoginDataModel!
    
    class func sharedLoginDataModel() -> TYLoginDataModel {
        if sharedLoginDataModelObj == nil {
            sharedLoginDataModelObj = self.restore()
            if (sharedLoginDataModelObj == nil) {
                sharedLoginDataModelObj = TYLoginDataModel()
            }
        }
        return sharedLoginDataModelObj
    }
    
    class func restore() -> TYLoginDataModel? {
        let encodedLoginDataMode = UserDefaults.standard.object(forKey: kSavedLoginDataModelKey)
        if encodedLoginDataMode != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: encodedLoginDataMode as! Data) as? TYLoginDataModel
        }
        else {
            return nil
        }
    }
    
    func commit() {
        let defaults = UserDefaults.standard
        let encodedLoginDataModel = NSKeyedArchiver.archivedData(withRootObject: TYLoginDataModel.sharedLoginDataModelObj)
        defaults.set(encodedLoginDataModel, forKey: TYLoginDataModel.kSavedLoginDataModelKey)
        defaults.synchronize()
    }
    
    func loginWithUser(username : String) {
                TYLoginDataModel.sharedLoginDataModel().username = String(format : "%@", username) as NSString
        TYLoginDataModel.sharedLoginDataModel().valid = true
        NotificationCenter.default.post(name: Notification.Name(TYLoginDataModel.TYUserAuthSucceededNotification), object: self)
        self.commit()
    }
    
    func checkLogin() -> Bool {
        if !(self.valid) {
            return false
        }
        return true
    }

    func logout() {
        self.valid = false
        self.commit()
    
        self.username = nil
        self.key = nil
    }
    
    func encode(with aCoder: NSCoder) {
    
        let username_Data = (self.username).data(using:String.Encoding.utf8.rawValue)!
        aCoder.encode(username_Data, forKey: "username")
        
        aCoder.encode(self.valid as Bool, forKey: "valid")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()

        let username_Data = aDecoder.decodeObject(forKey: "username") as! Data
        let username_String = String(data: username_Data, encoding: String.Encoding.utf8)
        self.username = NSString(format: "%@", username_String!)
                
        self.valid = aDecoder.decodeBool(forKey: "valid")
    }
    
    func encryptData(_ clearTextData : Data, withPassword password : String) -> Dictionary<String, Data> {
        var setupSuccess = true
        var outDictionary = Dictionary<String, Data>.init()
        var key = Data(repeating:0, count:kCCKeySizeAES256)
        var salt = Data(count: 8)
        
        salt.withUnsafeMutableBytes { (saltBuffer: UnsafeMutableRawBufferPointer) in
            let saltBytes = saltBuffer.bindMemory(to: UInt8.self)
            let saltStatus = SecRandomCopyBytes(kSecRandomDefault, saltBytes.count, saltBytes.baseAddress!)
            if saltStatus == errSecSuccess {
                let passwordData = password.data(using: .utf8)!
                
                key.withUnsafeMutableBytes { (keyBuffer: UnsafeMutableRawBufferPointer) in
                    let keyBytes = keyBuffer.bindMemory(to: UInt8.self)
                    let derivationStatus = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, passwordData.count, saltBytes.baseAddress!, saltBytes.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 14271, keyBytes.baseAddress!, keyBytes.count)
                    if derivationStatus != Int32(kCCSuccess) {
                        setupSuccess = false
                    }
                }
                
            } else {
                setupSuccess = false
            }
        }
                 
        var iv = Data.init(count: kCCBlockSizeAES128)
        iv.withUnsafeMutableBytes { (ivBytes : UnsafeMutablePointer<UInt8>) in
            let ivStatus = SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes)
            if ivStatus != errSecSuccess
            {
                setupSuccess = false
            }
        }
         
        if (setupSuccess)
        {
            var numberOfBytesEncrypted : size_t = 0
            let size = clearTextData.count + kCCBlockSizeAES128
            var encrypted = Data.init(count: size)
            let cryptStatus = iv.withUnsafeBytes {ivBytes in
                encrypted.withUnsafeMutableBytes {encryptedBytes in
                clearTextData.withUnsafeBytes {clearTextBytes in
                    key.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes,
                                key.count,
                                ivBytes,
                                clearTextBytes,
                                clearTextData.count,
                                encryptedBytes,
                                size,
                                &numberOfBytesEncrypted)
                        }
                    }
                }
            }
            if cryptStatus == Int32(kCCSuccess)
            {
                encrypted.count = numberOfBytesEncrypted
                outDictionary["EncryptionData"] = encrypted
                outDictionary["EncryptionIV"] = iv
                outDictionary["EncryptionSalt"] = salt
            }
        }
     
        return outDictionary;
    }
    
    func decryp(fromDictionary dictionary : Dictionary<String, Data>, withPassword password : String) -> Data {
        var setupSuccess = true
        let encrypted = dictionary["EncryptionData"]
        let iv = dictionary["EncryptionIV"]
        let salt = dictionary["EncryptionSalt"]
        var key = Data(repeating:0, count:kCCKeySizeAES256)
        salt?.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>) -> Void in
            let passwordData = password.data(using:String.Encoding.utf8)!
            key.withUnsafeMutableBytes { (keyBuffer: UnsafeMutableRawBufferPointer) in
                let keyBytes = keyBuffer.bindMemory(to: UInt8.self)
                let derivationStatus = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, passwordData.count, saltBytes, salt!.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 14271, keyBytes.baseAddress!, keyBytes.count)
                if derivationStatus != Int32(kCCSuccess) {
                    setupSuccess = false
                }
            }
        }
         
        var decryptSuccess = false
        let size = (encrypted?.count)! + kCCBlockSizeAES128
        var clearTextData = Data.init(count: size)
        if (setupSuccess)
        {
            var numberOfBytesDecrypted : size_t = 0
            let cryptStatus = iv?.withUnsafeBytes {ivBytes in
                clearTextData.withUnsafeMutableBytes {clearTextBytes in
                encrypted?.withUnsafeBytes {encryptedBytes in
                    key.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES128),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes,
                                key.count,
                                ivBytes,
                                encryptedBytes,
                                (encrypted?.count)!,
                                clearTextBytes,
                                size,
                                &numberOfBytesDecrypted)
                        }
                    }
                }
            }
            if cryptStatus! == Int32(kCCSuccess)
            {
                clearTextData.count = numberOfBytesDecrypted
                decryptSuccess = true
            }
        }
         
        return decryptSuccess ? clearTextData : Data.init(count: 0)
    }

}
