//
//  ContourStruct.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 13/02/23.
//

import Foundation
import Vision

struct ContourStruct: Identifiable, Hashable {
  let id = UUID()
  let area: Double
  private let vnContour: VNContour

  init(vnContour: VNContour) {
    self.vnContour = vnContour
    self.area = vnContour.boundingBox.area
  }

  var normalizedPath: CGPath {
    self.vnContour.normalizedPath
  }

  var aspectRatio: CGFloat {
    CGFloat(self.vnContour.aspectRatio)
  }

  var boundingBox: CGRect {
    self.vnContour.boundingBox
  }
}
