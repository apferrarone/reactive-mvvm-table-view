//
//  ProfileViewController.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit
import PureLayout

class ProfileViewController: UIViewController
{
     private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01)) // hack for grouped top inset
        tableView.register(NameEmailCell.self, forCellReuseIdentifier: NameEmailCell.identifier)
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.identifier)
        tableView.register(KeyValueCell.self, forCellReuseIdentifier: KeyValueCell.identifier)
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.dataSource = self
        tableView.sectionFooterHeight = 24.0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .black
        return tableView
    }()
    
    let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel)
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupViews()
        self.bindToViewModel()
        self.viewModel.observeData()
    }
    
    // MARK: - Utilities
    
    private func bindToViewModel()
    {
        self.title = self.viewModel.title
        
        self.viewModel.applyChanges = { [tv = self.tableView] in
            tv.beginUpdates()
            tv.deleteSections($0.sectionsToDelete, with: .fade)
            tv.insertSections($0.sectionsToInsert, with: .fade)
            tv.reloadSections($0.sectionHeadersToReload, with: .fade)
            tv.deleteRows(at: $0.rowChanges.rowsToDelete, with: .fade)
            tv.insertRows(at: $0.rowChanges.rowsToInsert, with: .fade)
            tv.reloadRows(at: $0.rowChanges.rowsToReload, with: .fade)
            tv.endUpdates()
        }
    }
    
    private func setupViews()
    {
        self.view.backgroundColor = .black
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdges()
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let item = self.viewModel.items[section]
        return item.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = self.viewModel.items[indexPath.section]
        
        switch item.type {
        case .nameEmail:
            if let nameEmailItem = item as? ProfileViewModelNameEmailItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: NameEmailCell.identifier, for: indexPath) as? NameEmailCell {
                cell.name = nameEmailItem.name
                cell.email = nameEmailItem.email
                return cell
            }
            
        case .about:
            if let aboutItem = item as? ProfileViewModelAboutItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.identifier, for: indexPath) as? AboutCell {
                cell.aboutContent = aboutItem.aboutContent
                return cell
            }
                
        case .details:
            if let detailsItem = item as? ProfileViewModelDetailsItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: KeyValueCell.identifier, for: indexPath) as? KeyValueCell {
                let detail = detailsItem.details[indexPath.row]
                cell.key = detail.key
                cell.value = detail.value
                return cell
            }
            
        case .friends:
            if let friendsItem = item as? ProfileViewModelFriendsItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath) as? FriendCell {
                let friend = friendsItem.friends[indexPath.row]
                cell.name = friend.name
                cell.email = friend.email
                cell.imageUrl = URL(string: friend.imageUrl)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let item = self.viewModel.items[section]
        return item.sectionTitle
    }
}
