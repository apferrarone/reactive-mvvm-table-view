//
//  FriendCell.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell
{
    static var identifier: String {
        return String(describing: self)
    }
    
    private lazy var friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var name: String = "" {
        didSet {
            self.nameLabel.text = self.name
        }
    }
    
    var email: String = "" {
        didSet {
            self.emailLabel.text = self.email
        }
    }
    
    var imageUrl: URL? {
        didSet {
            self.friendImageView.image = nil
            self.fetchFriendImage()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    // MARK: - Utilities
    
    func fetchFriendImage()
    {
        if let url = self.imageUrl {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    // when we are finished downloading make sure the url we fetched is still the one we want to display
                    // if download takes a long time and we re-use cells, we might not want to display this one anymore
                    if let imageData = data, url == self?.imageUrl {
                        self?.friendImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    func initialize()
    {
        self.backgroundColor = .black
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.friendImageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.emailLabel)
        
        self.friendImageView.autoPinEdge(toSuperviewMargin: .left)
        self.friendImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.friendImageView.autoSetDimensions(to: CGSize(width: 48.0, height: 48.0))
        self.friendImageView.layer.cornerRadius = 24.0
        self.friendImageView.clipsToBounds = true
        
        self.nameLabel.autoPinEdge(.left, to: .right, of: self.friendImageView, withOffset: 12.0)
        self.nameLabel.autoPinEdge(toSuperviewMargin: .top, withInset: 4.0)
        self.nameLabel.autoPinEdge(toSuperviewMargin: .right)
        
        self.emailLabel.autoPinEdge(.top, to: .bottom, of: self.nameLabel, withOffset: 4.0)
        self.emailLabel.autoPinEdge(.left, to: .left, of: self.nameLabel)
        self.emailLabel.autoPinEdge(toSuperviewMargin: .right)
        self.emailLabel.autoPinEdge(toSuperviewMargin: .bottom, withInset: 4.0)
    }
}
