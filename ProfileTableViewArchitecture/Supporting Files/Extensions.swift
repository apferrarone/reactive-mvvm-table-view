//
//  Extensions.swift
//  ProfileTableViewArchitecture
//
//  Created by Andrew Ferrarone on 3/29/20.
//  Copyright © 2020 Andrew Ferrarone. All rights reserved.
//

import UIKit

extension UIView
{
    // fades bottom w/ translucent gradient, white if lightContent, otherwise black:
    func fadeBottomContent(lightContent: Bool, with color: UIColor)
    {
        let clear = color.withAlphaComponent(0.0).cgColor
        let otherColor = lightContent ? color.cgColor : UIColor.black.cgColor
        let colors: [CGColor] = [clear, otherColor]
        let locations: [NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension Array where Element: Hashable
{
    // Remove duplicates from the array, preserving the items order
    func filterDuplicates() -> Array<Element>
    {
        var set = Set<Element>()
        var filteredArray = Array<Element>()

        for item in self {
            // if it was successfully inserted into the set, it did not already exist and is unique
            if set.insert(item).inserted {
                filteredArray.append(item)
            }
        }

        return filteredArray
    }
}
