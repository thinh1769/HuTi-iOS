//
//  UIImage+Ext.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 03/04/2023.
//

import UIKit

extension UIImage {
    func rotate() -> UIImage {
            guard imageOrientation != UIImage.Orientation.up else {
                // This is default orientation, don't need to do anything
                return self
            }

            guard let cgImage = self.cgImage else {
                // CGImage is not available
                return self
            }

            guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return self // Not able to create CGContext
            }

            var transform: CGAffineTransform = CGAffineTransform.identity

            switch imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: CGFloat.pi)
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by: CGFloat.pi / 2.0)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: CGFloat.pi / -2.0)
            case .up, .upMirrored:
                break
            @unknown default:
                fatalError("Missing...")
                break
            }

            // Flip image one more time if needed to, this is to prevent flipped image
            switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .up, .down, .left, .right:
                break
            @unknown default:
                fatalError("Missing...")
                break
            }

            ctx.concatenate(transform)

            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                break
            }

            guard let newCGImage = ctx.makeImage() else { return self }
            return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
        }
}

