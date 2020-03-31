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
        
    var applyChanges: ((SectionChanges) -> Void)?
    var title = "Profile" // could be BOX

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
            newItems.append(ProfileViewModelAboutItem(aboutContent: about))
        }
        
        if let details = profile.details {
            newItems.append(ProfileViewModelDetailsItem(details: details))
        }
        
        if let friends = profile.friends {
            newItems.append(ProfileViewModelFriendsItem(friends: friends))
        }
        
        self.updateUI(with: newItems)
    }
    
    private func updateUI(with newItems: [ProfileViewModelItem])
    {
        // map the old and new items to reloadable sections
        let oldSectionData = self.getReloadableSections(from: self.items)
        let newSectionData = self.getReloadableSections(from: newItems)
        
        // get the diff, update the data source, and finally update the UI
        let sectionChanges = TableViewDiffCalculator().calculate(oldSections: oldSectionData, newSections: newSectionData)
        self.items = newItems
        self.applyChanges?(sectionChanges)
    }
    
    private func getReloadableSections(from items: [ProfileViewModelItem]) -> [ReloadableSection<RowItem>]
    {
        return items.enumerated().map {
            // for each section create a ReloadableRow for each of the row items
            // the value of the ReloadableRow is the row item
            let reladableRows = $0.element.rowItems.enumerated().map {
                ReloadableRow(key: $0.element.rowId, value: $0.element, index: $0.offset)
            }
            // create a ReloadableSection for each section w/ an array of ReloadableRows
            return ReloadableSection(key: $0.element.sectionId, rows: reladableRows, index: $0.offset)
        }
    }
}

// MARK: - ProfileViewModelItemTypes

// String as rawValue to use as section unique key for TableViewDiffCalculator
enum ProfileViewModelItemType: String
{
    case nameEmail, about, details, friends
}

struct RowItem: Equatable
{
    var value: CustomStringConvertible
    var rowId: String
    
    static func ==(lhs: RowItem, rhs: RowItem) -> Bool
    {
        return lhs.rowId == rhs.rowId && lhs.value.description == rhs.value.description
    }
}

protocol ProfileViewModelItem
{
    var sectionId: String { get }
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String? { get }
    var rowItems: [RowItem] { get }
}

struct ProfileViewModelNameEmailItem: ProfileViewModelItem
{
    let id: String
    let name: String
    let email: String?
    
    var sectionId: String {
        return self.type.rawValue
    }
    
    var type: ProfileViewModelItemType {
        return .nameEmail
    }
    
    var sectionTitle: String? {
        return nil
    }
    
    var rowItems: [RowItem] {
        return [RowItem(value: "\(self.name), \(self.email ?? "")", rowId: self.id)]
    }
}

struct ProfileViewModelAboutItem: ProfileViewModelItem
{
    let aboutContent: String
    
    var sectionId: String {
        return self.type.rawValue
    }
    
    var type: ProfileViewModelItemType {
        return .about
    }
    
    var sectionTitle: String? {
        return "ABOUT"
    }
    
    var rowItems: [RowItem] {
        return [RowItem(value: self.aboutContent, rowId: self.sectionTitle!)]
    }
}

struct ProfileViewModelDetailsItem: ProfileViewModelItem
{
    let details: [Attribute]
    
    var sectionId: String {
        return self.type.rawValue
    }
    
    var type: ProfileViewModelItemType {
        return .details
    }
    
    var sectionTitle: String? {
        return "DETAILS"
    }
    
    var rowItems: [RowItem] {
        return self.details.map { RowItem(value: $0, rowId: $0.key) }
    }
}

struct ProfileViewModelFriendsItem: ProfileViewModelItem
{
    var friends: [Friend]
    
    var sectionId: String {
        return self.type.rawValue
    }
    
    var type: ProfileViewModelItemType {
        return .friends
    }
    
    var sectionTitle: String? {
        return "FRIENDS"
    }
    
    var rowItems: [RowItem] {
        return self.friends.map { RowItem(value: $0, rowId: $0.id) }
    }
}

