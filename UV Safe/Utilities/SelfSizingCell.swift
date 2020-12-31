//
//  SelfSizingCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class SelfSizingCell: UICollectionViewCell {

    public static var defaultMinimumHeight: CGFloat {
        switch UIApplication.shared.preferredContentSizeCategory {
            case .extraSmall:
                return 44
            case .small:
                return 44
            default:
                return 50
        }
    }

    public var didCalculateHeight: ((_ cell: UICollectionViewCell, _ height: CGFloat) -> Void)?

    public var height: CGFloat?

    public var widthConstraint: NSLayoutConstraint?
    public var heightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        height = layoutAttributes.bounds.height

        if let height = height, let didCalculateHeight = didCalculateHeight {
            didCalculateHeight(self, height)
        }

        return layoutAttributes
    }

    public func setWidth(to width: CGFloat) {
        if let widthConstraint = widthConstraint {
            widthConstraint.constant = width
        } else {
            let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
            widthConstraint.priority = UILayoutPriority(999)
            widthConstraint.isActive = true

            self.widthConstraint = widthConstraint
        }
    }

    public func setHeight(to height: CGFloat) {
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        setHeight(with: heightConstraint)
    }

    public func setHeight(toAtLeast height: CGFloat) {
        let heightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        setHeight(with: heightConstraint)
    }

    public func setHeight(toAtMost height: CGFloat) {
        let heightConstraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: height)
        setHeight(with: heightConstraint)
    }

    private func setHeight(with constraint: NSLayoutConstraint) {
        if let heightConstraint = heightConstraint {
            heightConstraint.isActive = false
            self.removeConstraint(heightConstraint)
        }

        constraint.priority = UILayoutPriority(999)
        constraint.isActive = true

        self.heightConstraint = constraint
    }
}
