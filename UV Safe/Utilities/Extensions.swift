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

extension UIView {
    // Less Blur in Effects View from: https://stackoverflow.com/questions/29498884/less-blur-with-visual-effect-view-with-blur
    public func pauseAnimation() {
        let time = 0.2 + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }

    public func resumeAnimation() {
        let pausedTime = layer.timeOffset

        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
}

extension UIVisualEffectView {
    public func applyBlur(with blurEffect: UIBlurEffect) {
        self.pauseAnimation()
        UIView.animate(withDuration: 0.75) {
            self.effect = blurEffect
        }
    }
}
