//
//  FirebaseManager.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseManager {
    
    static var instance : FirebaseManager!
    
    class func getInstance() -> FirebaseManager {
        if instance == nil {
            instance = FirebaseManager()
        }
        return instance
    }
    
    let db = Firestore.firestore()
    
    public func saveUser(user: CoreUser, completion: (Error?) -> ()) {
        do {
            try db.collection("users").document().setData(from: user)
            completion(nil)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
            completion(error)
        }
    }
    
    public func saveLocationLog(log: LocationLog, completion: (Error?) -> ()) {
        do {
            try db.collection("user_logs")
                .document(TYLoginDataModel.sharedLoginDataModel().username as String)
                .collection("locations")
                .document()
                .setData(from: log)
            completion(nil)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
            completion(error)
        }
    }
    
}
