//
//  ProfileViewModel.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

// MARK: - ProfileViewModel

enum ProfileSection: Hashable {
    case songs
    case details
    case about
}

enum ProfileRow: Hashable {
    case song(Song)
    case detail(Attribute)
    case about(content: String)
}

final class ProfileViewModel {
    struct State {
        var name: String?
        var listeners: String?
        var imageUrl: String?
        var aboutTitle: String?
        var sections: [(ProfileSection, [ProfileRow])] = []
    }

    private(set) var state = State() {
        didSet { self.onChange?(state) }
    }

    var onChange: ((State) -> Void)?

    func observeData() {
        Connector.shared.observeData { [weak self] profile in
            guard let self else { return }
            self.state = Self.makeState(from: profile)
        }
    }

    private static func makeState(from profile: Profile) -> State {
        var s = State()
        s.name = profile.name
        s.listeners = profile.listeners
        s.imageUrl = profile.imageUrl

        var sections: [(ProfileSection, [ProfileRow])] = []

        if let songs = profile.songs {
            let rows = songs.map { ProfileRow.song($0) }
            sections.append((.songs, rows))
        }

        if let details = profile.details {
            let rows = details.map { ProfileRow.detail($0) }
            sections.append((.details, rows))
        }

        if let about = profile.about {
            s.aboutTitle = about.title.capitalized
            sections.append((.about, [.about(content: about.content)]))
        }

        s.sections = sections
        return s
    }
}
