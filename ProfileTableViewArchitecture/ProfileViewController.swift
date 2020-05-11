//
//  ProfileViewController.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit
import PureLayout
import SDWebImage

private let HEIGHT_HEADER: CGFloat = 360.0

class ProfileViewController: UIViewController
{
    private lazy var headerImageView: HeaderView = {
        let view = HeaderView()
        view.backgroundColor = .gray
        view.contentMode = .scaleAspectFill
        return view
    }()
            
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.identifier)
        tableView.register(KeyValueCell.self, forCellReuseIdentifier: KeyValueCell.identifier)
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        tableView.sectionHeaderHeight = 64.0
        tableView.sectionFooterHeight = 24.0
        tableView.contentInset.bottom = 100.0
        tableView.estimatedRowHeight = 77.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .black
        return tableView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var isShowingNavBar = false
    
    let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel)
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setupViews()
        self.bindToViewModel()
        self.viewModel.observeData()
    }
    
    // MARK: - Utilities
    
    private func bindToViewModel()
    {
        self.viewModel.profileName.bind { [unowned self] name in
            UIView.transition(with: self.headerImageView.nameLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.headerImageView.nameLabel.text = name
            }, completion: nil)
            self.title = name
        }
        
        self.viewModel.profileListeners.bind { [hv = self.headerImageView] listeners in
            UIView.transition(with: self.headerImageView.subtitleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                hv.subtitleLabel.text = listeners
            }, completion: nil)
        }
        
        self.viewModel.profileImageUrl.bind { [hv = self.headerImageView] imageUrl in
            if let path = imageUrl, let url = URL(string: path) {
                UIView.transition(with: self.headerImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    hv.sd_setImage(with: url)
                }, completion: nil)
            }
        }
        
        self.viewModel.applyChanges = { [tv = self.tableView] in
            tv.beginUpdates()
            tv.deleteSections($0.sectionsToDelete, with: .fade)
            tv.insertSections($0.sectionsToInsert, with: .fade)
            tv.deleteRows(at: $0.rowChanges.rowsToDelete, with: .fade)
            tv.insertRows(at: $0.rowChanges.rowsToInsert, with: .fade)
            tv.reloadRows(at: $0.rowChanges.rowsToReload, with: .fade)
            
            // reload the section headers
            $0.sectionHeaderReloads.forEach { section in
                if let header = tv.headerView(forSection: section) as? SectionHeaderView {
                    UIView.transition(with: header.titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        let item = self.viewModel.items[section]
                        header.titleLabel.text = item.sectionTitle
                    }, completion: nil)
                }
            }
            
            tv.endUpdates()
        }
    }
    
    private func setupViews()
    {
        self.view.backgroundColor = .black
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdges()
        self.tableView.addSubview(self.headerImageView)
        self.tableView.contentInset.top = HEIGHT_HEADER
        self.tableView.contentOffset = CGPoint(x: 0, y: -HEIGHT_HEADER)
        self.updateHeader()
    }
    
    private func updateHeader()
    {
        self.headerImageView.translatesAutoresizingMaskIntoConstraints = true
                
        var headerRect = CGRect(x: 0, y: -HEIGHT_HEADER, width: self.tableView.bounds.width, height: HEIGHT_HEADER)
        if self.tableView.contentOffset.y < -HEIGHT_HEADER {
            headerRect.origin.y = self.tableView.contentOffset.y
            headerRect.size.height = -self.tableView.contentOffset.y
        }
        
        self.headerImageView.frame = headerRect
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
            
        case .songs:
            if let songsItem = item as? ProfileViewModelSongsItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as? SongCell {
                let song = songsItem.songs[indexPath.row]
                cell.song = song
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let item = self.viewModel.items[section]
        
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as? SectionHeaderView {
            headerView.titleLabel.text = item.sectionTitle
            return headerView
        }

        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.updateHeader()
        
        if self.tableView.contentOffset.y <= -160 && !self.isShowingNavBar {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.isShowingNavBar = true
        }
        else if self.tableView.contentOffset.y > -160 && self.isShowingNavBar {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.isShowingNavBar = false
        }
    }
}
