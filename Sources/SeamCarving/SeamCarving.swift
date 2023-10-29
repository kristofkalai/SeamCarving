//
//  SeamCarving.swift
//
//
//  Created by Kristóf Kálai on 29/10/2023.
//

import Internal

public struct SeamCarving {
    private let seamCarvingCore: SeamCarvingCore
}

extension SeamCarving {
    public init(image: UIImage) {
        self.init(seamCarvingCore: .init(image: image))
    }
}

extension SeamCarving {
    public var carved: UIImage {
        seamCarvingCore.carve()
    }
}
