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
    let listeners: String?
    let imageUrl: String?
    let about: AboutContent?
    let details: [Attribute]?
    let songs: [Song]?
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

struct Song: Codable
{
    let id: String
    let title: String
    let subtitle: String
    let imageUrl: String
}

extension Song: CustomStringConvertible
{
    var description: String {
        return "\(self.id), \(self.title), \(self.subtitle), \(self.imageUrl)"
    }
}
