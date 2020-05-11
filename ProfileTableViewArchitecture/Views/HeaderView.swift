//
//  HeaderView.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 4/6/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

class HeaderView: UIImageView
{
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "AvenirNext-Bold", size: 32.0)!
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont(name: "AvenirNext-Regular", size: 14.0)!
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var playButtonView: UIImageView = {
        let image = UIImage(named: "play-button")
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var bottomGradient = CAGradientLayer()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupViews()
    }
    
    override init(image: UIImage?)
    {
        super.init(image: image)
        self.setupViews()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?)
    {
        super.init(image: image, highlightedImage: highlightedImage)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.updateGradient()
    }
    
    private func setupViews()
    {
        self.clipsToBounds = true
        self.addSubview(self.nameLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.playButtonView)

        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            self.nameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
            self.nameLabel.autoPinEdge(.right, to: .left, of: self.playButtonView, withOffset: -12.0)

            self.subtitleLabel.autoPinEdge(.top, to: .bottom, of: self.nameLabel, withOffset: 8.0)
            self.subtitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
            self.subtitleLabel.autoPinEdge(.right, to: .left, of: self.playButtonView, withOffset: -12.0)
            self.subtitleLabel.autoPinEdge(toSuperviewMargin: .bottom)
            
            self.playButtonView.autoPinEdge(toSuperviewEdge: .right, withInset: 18.0)
            self.playButtonView.autoPinEdge(toSuperviewMargin: .bottom)
            self.playButtonView.autoSetDimensions(to: CGSize(width: 44.0, height: 44.0))
        }
        
        self.nameLabel.setContentHuggingPriority(.required, for: .vertical)
        self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    private func updateGradient()
    {
        let newGradient = UIView.bottomContentFadeLayer(for: self, with: .black)
        
        if let sublayers = self.layer.sublayers, sublayers.contains(self.bottomGradient) {
            self.layer.replaceSublayer(self.bottomGradient, with: newGradient)
        }
        else {
            self.layer.insertSublayer(newGradient, at: 0)
        }
        
        self.bottomGradient = newGradient
    }
}
