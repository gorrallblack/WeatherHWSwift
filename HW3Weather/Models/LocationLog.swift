//
//  LocationLog.swift

import Foundation


public struct LocationLog: Codable {

    let userId: String
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let timestamp : Int64?

    enum CodingKeys: String, CodingKey {
        case userId
        case city
        case country
        case latitude
        case longitude
        case timestamp
    }

}
