//
//  GroupSession.swift
//  FoodChoice
//
//  Created by Donald Echefu on 4/30/23.
//
import Foundation
import ParseSwift

struct GroupSession: ParseObject, Codable {
    // Remove the init() function if it's not needed, or provide an implementation.
    init() {
        inviter = ""
        message = ""
        isRead = false
        numPeep = 0
        track = 0
    }

    static var parseClassName: String {
            return "GroupSession"
        }
    init(recipient: User, inviter: String, message: String, num: Int, track: Int) {
        self.recipient = try? Pointer(recipient)
        self.inviter = inviter
        self.message = message
        self.isRead = false
        self.numPeep = num
        self.track = track
    }
    
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    var recipient: Pointer<User>?
    var inviter: String
    var message: String
    var isRead: Bool
    var numPeep: Int
    var track: Int

    enum CodingKeys: String, CodingKey {
        case objectId
        case createdAt
        case updatedAt
        case ACL
        case recipient
        case inviter
        case message
        case isRead
        case numPeep
        case track
    }
}
