//
//  SongCell.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit
import SDWebImage

class SongCell: UITableViewCell
{
    static var identifier: String {
        return String(describing: self)
    }
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Medium", size: 17.0)!
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont(name: "AvenirNext-Regular", size: 14.0)!
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var song: Song? {
        didSet {
            if let song = self.song {
                self.titleLabel.text = song.title
                self.subtitleLabel.text = song.subtitle
                self.thumbnailImageView.sd_setImage(with: URL(string: song.imageUrl))
            }
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
    
    func initialize()
    {
        self.backgroundColor = .black
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.thumbnailImageView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.subtitleLabel)
                
        self.thumbnailImageView.autoPinEdge(toSuperviewMargin: .left)
        self.thumbnailImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.thumbnailImageView.autoSetDimensions(to: CGSize(width: 44.0, height: 44.0))
        self.thumbnailImageView.layer.cornerRadius = 10.0
        self.thumbnailImageView.clipsToBounds = true
        
        self.titleLabel.autoPinEdge(.left, to: .right, of: self.thumbnailImageView, withOffset: 12.0)
        self.titleLabel.autoPinEdge(toSuperviewMargin: .top)
        self.titleLabel.autoPinEdge(toSuperviewMargin: .right)
        
        self.subtitleLabel.autoPinEdge(.top, to: .bottom, of: self.titleLabel, withOffset: 4.0)
        self.subtitleLabel.autoPinEdge(.left, to: .left, of: self.titleLabel)
        self.subtitleLabel.autoPinEdge(.left, to: .right, of: self.thumbnailImageView, withOffset: 12.0)
        self.subtitleLabel.autoPinEdge(toSuperviewMargin: .right)
        self.subtitleLabel.autoPinEdge(toSuperviewMargin: .bottom)
    }
}
