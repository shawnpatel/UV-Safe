//
//  Extensions.swift
//  UV Safe
//
//  Created by Shawn Patel on 1/1/21.
//  Copyright © 2021 Shawn Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
