//
//  ProfileViewModel.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

// MARK: - ProfileViewModel

final class ProfileViewModel: NSObject
{
    private(set) var items = [ProfileViewModelItem]()
        
    var title = "Profile" // could be BOX
    var applyChanges: ((SectionChanges) -> Void)?

    func observeData()
    {
        Connector.shared.observeData { (profile) in
            self.update(with: profile)
        }
    }
    
    private func update(with profile: Profile)
    {
        var newItems: [ProfileViewModelItem] = []
        
        if let id = profile.id, let name = profile.name {
            newItems.append(ProfileViewModelNameEmailItem(id: id, name: name, email: profile.email))
        }
        
        if let about = profile.about {
            newItems.append(ProfileViewModelAboutItem(aboutTitle: about.title, aboutContent: about.content))
        }
        
        if let details = profile.details {
            newItems.append(ProfileViewModelDetailsItem(details: details))
        }
        
        if let friends = profile.friends {
            newItems.append(ProfileViewModelFriendsItem(friends: friends))
        }
        
        // get the diff, update the data source, and finally update the UI
        let sectionChanges = TableViewDiffCalculator().calculateChanges(oldSections: self.items, newSections: newItems)
        self.items = newItems
        self.applyChanges?(sectionChanges)
    }
}

// MARK: - ProfileViewModelItemTypes

protocol ProfileViewModelItem: ReloadableSection
{
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String? { get }
}

extension ProfileViewModelItem
{
    var sectionId: String {
        return self.type.rawValue
    }
}

// String as rawValue to use as unique sectionId for TableViewDiffCalculator
enum ProfileViewModelItemType: String
{
    case nameEmail, about, details, friends
}

struct ProfileViewModelNameEmailItem: ProfileViewModelItem
{
    let id: String
    let name: String
    let email: String?
    
    var type: ProfileViewModelItemType {
        return .nameEmail
    }
    
    var sectionTitle: String? {
        return nil
    }
    
    var rows: [ReloadableRow] {
        return [ReloadableRow(id: self.id, value: "\(self.name), \(self.email ?? "")")]
    }
}

struct ProfileViewModelAboutItem: ProfileViewModelItem
{
    let aboutTitle: String
    let aboutContent: String
    
    var type: ProfileViewModelItemType {
        return .about
    }
    
    var sectionTitle: String? {
        return self.aboutTitle.uppercased()
    }
    
    var sectionHeader: ReloadableSectionHeader? {
        return ReloadableSectionHeader(value: self.aboutTitle)
    }
    
    var rows: [ReloadableRow] {
        return [ReloadableRow(id: self.sectionId, value: self.aboutContent)]
    }
    
}

struct ProfileViewModelDetailsItem: ProfileViewModelItem
{
    let details: [Attribute]
    
    var type: ProfileViewModelItemType {
        return .details
    }
    
    var sectionTitle: String? {
        return "DETAILS"
    }
    
    var rows: [ReloadableRow] {
        return self.details.map { ReloadableRow(id: $0.key, value: $0) }
    }
}

struct ProfileViewModelFriendsItem: ProfileViewModelItem
{
    var friends: [Friend]
    
    var type: ProfileViewModelItemType {
        return .friends
    }
    
    var sectionTitle: String? {
        return "FRIENDS"
    }
    
    var rows: [ReloadableRow] {
        return self.friends.map { ReloadableRow(id: $0.id, value: $0) }
    }
}

