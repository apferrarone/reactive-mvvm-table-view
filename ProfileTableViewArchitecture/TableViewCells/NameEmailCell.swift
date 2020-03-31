//
//  NameEmailCell.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class NameEmailCell: UITableViewCell
{
    static var identifier: String {
        return String(describing: self)
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.numberOfLines = 2
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
    
    var email: String? {
        didSet {
            self.emailLabel.text = self.email
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
    
    func initialize()
    {
        self.backgroundColor = UIColor.black
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.emailLabel)
        
        self.nameLabel.autoPinEdge(toSuperviewMargin: .top)
        self.nameLabel.autoPinEdge(toSuperviewMargin: .left)
        self.nameLabel.autoPinEdge(toSuperviewMargin: .right)
        
        self.emailLabel.autoPinEdge(.top, to: .bottom, of: self.nameLabel, withOffset: 8.0)
        self.emailLabel.autoPinEdge(toSuperviewMargin: .left)
        self.emailLabel.autoPinEdge(toSuperviewMargin: .right)
        self.emailLabel.autoPinEdge(toSuperviewMargin: .bottom)
    }
}
