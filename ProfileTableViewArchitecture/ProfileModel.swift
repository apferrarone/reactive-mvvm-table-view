//
//  ProfileModel.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import Foundation

struct Profile: Codable
{
    let id: String?
    let name: String?
    let email: String?
    let about: AboutContent?
    let details: [Attribute]?
    let friends: [Friend]?
}

struct AboutContent: Codable
{
    let title: String
    let content: String
}

struct Attribute: Codable
{
    let key: String
    let value: String
}

extension Attribute: CustomStringConvertible
{
    var description: String {
        return "\(self.key), \(self.value)"
    }
}

struct Friend: Codable
{
    let id: String
    let name: String
    let email: String
    let imageUrl: String
}

extension Friend: CustomStringConvertible
{
    var description: String {
        return "\(self.id), \(self.name), \(self.email), \(self.imageUrl)"
    }
}
