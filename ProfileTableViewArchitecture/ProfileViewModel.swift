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
        
    var profileName: Box<String?> = Box(nil)
    var profileListeners: Box<String?> = Box(nil)
    var profileImageUrl: Box<String?> = Box(nil)
    
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
        
        self.profileName.value = profile.name
        self.profileListeners.value = profile.listeners
        self.profileImageUrl.value = profile.imageUrl
        
        if let songs = profile.songs {
            newItems.append(ProfileViewModelSongsItem(songs: songs))
        }
        
        if let details = profile.details {
            newItems.append(ProfileViewModelDetailsItem(details: details))
        }
        
        if let about = profile.about {
            newItems.append(ProfileViewModelAboutItem(aboutTitle: about.title, aboutContent: about.content))
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
    case about, details, songs
}

struct ProfileViewModelAboutItem: ProfileViewModelItem
{
    let aboutTitle: String
    let aboutContent: String
    
    var type: ProfileViewModelItemType {
        return .about
    }
    
    var sectionTitle: String? {
        return self.aboutTitle.capitalized
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
        return "Details"
    }
    
    var rows: [ReloadableRow] {
        return self.details.map { ReloadableRow(id: $0.key, value: $0) }
    }
}

struct ProfileViewModelSongsItem: ProfileViewModelItem
{
    var songs: [Song]
    
    var type: ProfileViewModelItemType {
        return .songs
    }
    
    var sectionTitle: String? {
        return "Songs"
    }
    
    var rows: [ReloadableRow] {
        return self.songs.map { ReloadableRow(id: $0.id, value: $0) }
    }
}

