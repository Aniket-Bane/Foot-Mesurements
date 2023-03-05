//
//  Phase1.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 20/02/23.
//

import Foundation
import UIKit
import ARKit
import CoreML
import CreateMLComponents
import CoreImage
import Vision
import Accelerate
class preProcess {
    static let instace = preProcess()

    func assumeCrop(image: UIImage, width: Double, height: Double) -> UIImage {

        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)

        let contextSize: CGSize = contextImage.size

        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
    

    
    func convertRGBToHSV(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        var pixelBuffer = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let context = CGContext(data: &pixelBuffer,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)!
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        for i in 0..<width * height {
            let offset = i * bytesPerPixel
            let red = Float(pixelBuffer[offset + 0]) / 255.0
            let green = Float(pixelBuffer[offset + 1]) / 255.0
            let blue = Float(pixelBuffer[offset + 2]) / 255.0
            
            var hue: Float = 0.0
            var saturation: Float = 0.0
            var brightness: Float = 0.0
            
            let cmax = max(max(red, green), blue)
            let cmin = min(min(red, green), blue)
            let delta = cmax - cmin
            
            if delta != 0 {
                if cmax == red {
                    hue = 60 * (((green - blue) / delta).truncatingRemainder(dividingBy: 6))
                } else if cmax == green {
                    hue = 60 * (((blue - red) / delta) + 2) + 120
                } else {
                    hue = 60 * (((red - green) / delta) + 4) + 240
                }
                saturation = delta / cmax
            }
            brightness = cmax * 0.5
            hue = max(0, min(hue, 180))
            saturation = max(0, min(saturation * 255, 255))
            brightness = max(0, min(brightness * 255, 255))
            
            pixelBuffer[offset + 0] = UInt8(hue)
            pixelBuffer[offset + 1] = UInt8(saturation)
            pixelBuffer[offset + 2] = UInt8(brightness)
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)
        return outputImage
    }
    
    func convertRGBToHSV2(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        var pixelBuffer = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let context = CGContext(data: &pixelBuffer,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)!
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        for i in 0..<width * height {
            let offset = i * bytesPerPixel
            let red = Float(pixelBuffer[offset + 0]) / 255.0
            let green = Float(pixelBuffer[offset + 1]) / 255.0
            let blue = Float(pixelBuffer[offset + 2]) / 255.0
            
            var hue: Float = 0.0
            var saturation: Float = 0.0
            var brightness: Float = 0.0
            
            let cmax = max(max(red, green), blue)
            let cmin = min(min(red, green), blue)
            let delta = cmax - cmin
            
            if delta != 0 {
                if cmax == red {
                    hue = 60 * (((green - blue) / delta).truncatingRemainder(dividingBy: 6))
                } else if cmax == green {
                    hue = 60 * (((blue - red) / delta) + 2) + 120
                } else {
                    hue = 60 * (((red - green) / delta) + 4) + 240
                }
                saturation = delta / cmax
            }
            brightness = cmax * 0.5
            // Clamp the values to the valid range
            hue = max(0, min(hue, 180))
            saturation = max(0, min(saturation * 255, 255))
            brightness = max(0, min(brightness * 255, 255))
            
            pixelBuffer[offset + 0] = UInt8(hue)
            pixelBuffer[offset + 1] = UInt8(saturation)
            pixelBuffer[offset + 2] = UInt8(brightness)
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)
        return outputImage
    }
    
    func applyGaussianBlur(to image: UIImage) -> UIImage? {
        guard let inputImage = CIImage(image: image) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(1.5, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)
        return blurredImage
    }
    
    func applyGaussianBlur2(to image: UIImage) -> UIImage? {
        guard let inputImage = CIImage(image: image) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.5, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)
        return blurredImage
    }
    
    func normalizeImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        var pixelBuffer = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let context = CGContext(data: &pixelBuffer,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)!

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        for i in 0..<width * height {
            let offset = i * bytesPerPixel
            let red = Float(pixelBuffer[offset + 0]) / 255.0
            let green = Float(pixelBuffer[offset + 1]) / 255.0
            let blue = Float(pixelBuffer[offset + 2]) / 255.0

            pixelBuffer[offset + 0] = UInt8(red * 255)
            pixelBuffer[offset + 1] = UInt8(green * 255)
            pixelBuffer[offset + 2] = UInt8(blue * 255)
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)

        return outputImage
    }
    
    func normalizeImage2(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        var pixelBuffer = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let context = CGContext(data: &pixelBuffer,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)!

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        for i in 0..<width * height {
            let offset = i * bytesPerPixel
            let red = Float(pixelBuffer[offset + 0]) / 255.0
            let green = Float(pixelBuffer[offset + 1]) / 255.0
            let blue = Float(pixelBuffer[offset + 2]) / 255.0

            pixelBuffer[offset + 0] = UInt8(red * 255)
            pixelBuffer[offset + 1] = UInt8(green * 255)
            pixelBuffer[offset + 2] = UInt8(blue * 255)
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)

        return outputImage
    }

    

}
