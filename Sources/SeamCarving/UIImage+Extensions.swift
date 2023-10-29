//
//  UIImage+Extensions.swift
//
//
//  Created by Kristóf Kálai on 29/10/2023.
//

import UIKit

extension UIImage {
    public var seamCarved: UIImage {
        SeamCarving(image: self).carved
    }
}
