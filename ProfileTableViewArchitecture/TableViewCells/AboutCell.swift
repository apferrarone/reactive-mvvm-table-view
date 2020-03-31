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
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        self.aboutLabel.autoPinEdgesToSuperviewMargins()
    }
}

