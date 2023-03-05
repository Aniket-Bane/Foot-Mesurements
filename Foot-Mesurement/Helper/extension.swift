//
//  VNContour.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 13/02/23.
//

import Foundation
import CoreGraphics
import UIKit
import Vision

extension VNContour {
  var boundingBox: CGRect {
    var minX: Float = 1.0
    var minY: Float = 1.0
    var maxX: Float = 0.0
    var maxY: Float = 0.0

    for point in normalizedPoints {
      if point.x < minX {
        minX = point.x
      } else if point.x > maxX {
        maxX = point.x
      }

      if point.y < minY {
        minY = point.y
      } else if point.y > maxY {
        maxY = point.y
      }
    }
  var width = Double(maxX - minX)
  var height = Double(maxY - minY)
    
    var Rectangle = CGRect(
      x: Double(minX),
      y: Double(minY),
      width: Double(maxX - minX),
      height: Double(maxY - minY))
    return Rectangle
  }
}

extension CGRect {
    var area: Double {
        width * height
    }
}

extension UIImage {
    func crop(rect: CGRect) -> UIImage? {
        guard let imageRef = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = removingDuplicates()
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
    
    public static func == (lhs: CGRect, rhs: CGRect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
  }


