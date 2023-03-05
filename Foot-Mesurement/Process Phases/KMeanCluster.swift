//
//  KMeanCluster.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 08/02/23.

import Foundation
import UIKit
import SimpleMatrixKit
import SwiftCluster

class KMeansClusterer {
    static let instace = KMeansClusterer()
    
    func ClusterImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            preconditionFailure("Unable to read image data.")
        }
        let width = cgImage.width
        let height = cgImage.height
        let pixelData = cgImage.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var pixels: [[Double]] = []
        for i in 0..<width*height {
            let offset = i * 4
            let red = Double(data[offset])
            let green = Double(data[offset+1])
            let blue = Double(data[offset+2])
            pixels.append([red, green, blue])
        }
        let pixelColorData = Matrix(array2D: pixels)
        let model = ClusterModel(
            data: pixelColorData,
            numberOfGroups: 2,
            initializationRule: .av,
            stoppingRules: [.distanceChange(percent: 0.01), .iterations(maximum: 15)],
            showDiagnostics: true
        )
        let (groupIDs, meanColors) = model.run()
        let pixelPosterizedColors = groupIDs.map{ meanColors.getRow($0) }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            preconditionFailure("Unable to create context.")
        }
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let color = pixelPosterizedColors[index]
                let red = UInt8(color[0])
                let green = UInt8(color[1])
                let blue = UInt8(color[2])
                let alpha: UInt8 = 255
                let pixel = (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | UInt32(blue)
                let offset = 4 * (y * width + x)
                context.data?.storeBytes(of: pixel, toByteOffset: offset, as: UInt32.self)
            }
        }
        guard let cgImage = context.makeImage() else {
            preconditionFailure("Unable to create CGImage.")
        }
        let outputImage = UIImage(cgImage: cgImage)
        return outputImage
    }
}
