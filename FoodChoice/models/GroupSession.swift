//
//  GroupSession.swift
//  FoodChoice
//
//  Created by Donald Echefu on 4/30/23.
//

import Foundation
import ParseSwift

struct InAppNotification: ParseObject, Codable {
    init() {
        <#code#>
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

    init(recipient: User, inviter: String, message: String) {
        self.recipient = try? Pointer(recipient)
        self.inviter = inviter
        self.message = message
        self.isRead = false
    }

    enum CodingKeys: String, CodingKey {
        case objectId
        case createdAt
        case updatedAt
        case ACL
        case recipient
        case inviter
        case message
        case isRead
    }
}
