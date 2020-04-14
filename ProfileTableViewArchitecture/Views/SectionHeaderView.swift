//
//  SectionHeaderView.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 4/6/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView
{
    static var identifier: String {
        return String(describing: self)
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 22.0)!
        label.textColor = .white
        return label
    }()
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize()
    {
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.autoPinEdge(toSuperviewMargin: .left)
        self.titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8.0)
        self.titleLabel.autoPinEdge(toSuperviewMargin: .right)
    }
}
