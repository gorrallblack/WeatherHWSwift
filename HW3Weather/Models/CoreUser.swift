//
//  CoreUser.swift

import Foundation

struct CoreUser: Codable {

    let username: String?
    let timestamp : Int64?
    
    enum CodingKeys: String, CodingKey {
        case username, timestamp
    }

}
