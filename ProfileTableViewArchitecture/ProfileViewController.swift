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
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.identifier)
        tableView.register(KeyValueCell.self, forCellReuseIdentifier: KeyValueCell.identifier)
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderView.identifier)
        tableView.sectionHeaderHeight = 64.0
        tableView.sectionFooterHeight = 12.0
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
    
    let viewModel: ProfileViewModel
    private var dataSource: UITableViewDiffableDataSource<ProfileSection, ProfileRow>!
    private var currentState: ProfileViewModel.State?
    
    private var isShowingNavBar = false

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
        self.setupDataSource()
        
        // bind to view model and start listening for data/state changes
        viewModel.onChange = { [weak self] state in
            self?.render(state)
        }
        
        self.viewModel.observeData()
    }
    
    // MARK: - Utilities
    
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
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<ProfileSection, ProfileRow>(tableView: tableView) { tableView, indexPath, row in
            switch row {
            case let .song(song):
                let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
                cell.song = song
                return cell

            case let .detail(attr):
                let cell = tableView.dequeueReusableCell(withIdentifier: KeyValueCell.identifier, for: indexPath) as! KeyValueCell
                cell.key = attr.key
                cell.value = attr.value
                return cell

            case let .about(content):
                let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.identifier, for: indexPath) as! AboutCell
                cell.aboutContent = content
                return cell
            }
        }
        
        self.tableView.dataSource = dataSource
    }
    
    private func render(_ newState: ProfileViewModel.State) {
        // capture currentState (now oldState) before updating it w/ new state
        let oldState = currentState
        currentState = newState

        /* Header text changes */
        
        if oldState?.name != newState.name {
            UIView.transition(with: headerImageView.nameLabel, duration: 0.35, options: .transitionCrossDissolve) {
                self.headerImageView.nameLabel.text = newState.name
            }
            self.title = newState.name // title for navbar
        }

        if oldState?.listeners != newState.listeners {
            UIView.transition(with: headerImageView.subtitleLabel, duration: 0.35, options: .transitionCrossDissolve) {
                self.headerImageView.subtitleLabel.text = newState.listeners
            }
        }

        if oldState?.imageUrl != newState.imageUrl,
           let path = newState.imageUrl,
           let url = URL(string: path) {
            UIView.transition(with: headerImageView, duration: 0.35, options: .transitionCrossDissolve) {
                self.headerImageView.sd_setImage(with: url)
            }
        }
        
        /* Table View Updates */

        // create new state for tableview from view model state
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileRow>()
        for (section, rows) in newState.sections {
            snapshot.appendSections([section])
            snapshot.appendItems(rows, toSection: section)
        }
        
        // animate table view changes
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve) {
            self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in // use fade animation instead ^
                self?.reloadVisibleSectionHeaders()
            }
        }
    }
    
    private func reloadVisibleSectionHeaders() {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }

        // get unique visible sections
        let visibleSections = Set(visibleIndexPaths.map { $0.section })

        for sectionIndex in visibleSections {
            guard
                let header = tableView.headerView(forSection: sectionIndex) as? SectionHeaderView,
                let sectionID = dataSource.sectionIdentifier(for: sectionIndex)
            else { continue }

            let newTitle = headerTitle(for: sectionID)

            // Only animate if text actually changed
            if header.titleLabel.text != newTitle {
                UIView.transition(
                    with: header.titleLabel,
                    duration: 0.35,
                    options: .transitionCrossDissolve,
                    animations: {
                        header.titleLabel.text = newTitle
                    }
                )
            }
        }
    }
    
    // called on scrollViewDidScroll
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
    
    private func headerTitle(for section: ProfileSection) -> String? {
        switch section {
        case .songs: return "Top Songs"
        case .details: return "Details"
        case .about: return currentState?.aboutTitle
        }
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        guard
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.identifier) as? SectionHeaderView,
            let sectionID = dataSource.sectionIdentifier(for: sectionIndex)
        else { return nil }

        header.titleLabel.text = headerTitle(for: sectionID)
        return header
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
