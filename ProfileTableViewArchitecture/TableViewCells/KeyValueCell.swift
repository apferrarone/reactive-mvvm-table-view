//
//  KeyValueCell.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class KeyValueCell: UITableViewCell
{
    static var identifier: String {
        return String(describing: self)
    }
    
    private(set) var keyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private(set) var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    private(set) var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    var key: String = "" {
        didSet {
            self.keyLabel.text = self.key
        }
    }
    
    var value: String = "" {
        didSet {
            self.valueLabel.text = self.value
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
        self.setupViews()
    }
    
    private func setupViews()
    {
        self.backgroundColor = .black
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.keyLabel)
        self.contentView.addSubview(self.valueLabel)
        self.contentView.addSubview(self.separator)
                
        self.keyLabel.autoPinEdge(toSuperviewMargin: .left)
        self.keyLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 14.0)
        self.keyLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 18.0)
        self.keyLabel.rightAnchor.constraint(lessThanOrEqualTo: self.valueLabel.leftAnchor, constant: -16.0).isActive = true
        
        self.valueLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 14.0)
        self.valueLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 18.0)
        self.valueLabel.autoPinEdge(toSuperviewMargin: .right)
        
        self.separator.autoSetDimension(.height, toSize: 1.0)
        self.separator.autoPinEdge(toSuperviewMargin: .left)
        self.separator.autoPinEdge(toSuperviewMargin: .right)
        self.separator.autoPinEdge(toSuperviewEdge: .bottom)
    }
}
