//
//  File.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell
{
    static var identifier: String {
        return String(describing: self)
    }
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Regular", size: 14.0)!
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var aboutContent: String = "" {
        didSet {
            self.aboutLabel.text = self.aboutContent
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
        
        self.contentView.addSubview(self.aboutLabel)
        self.aboutLabel.autoPinEdge(toSuperviewMargin: .left)
        self.aboutLabel.autoPinEdge(toSuperviewMargin: .right)
        self.aboutLabel.autoPinEdge(toSuperviewMargin: .top)
        self.aboutLabel.autoPinEdge(toSuperviewMargin: .bottom)
    }
}

