//
//  Phase4.swift
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

class findTheContours {
    static let instace = findTheContours()
    var points = ""
    
    func findPaperContours(_ image : UIImage , originalImage: UIImage) -> UIImage {
        let context = CIContext()
        var inputImage = CIImage.init(cgImage: image.cgImage!)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])
        try! requestHandler.perform([contourRequest])
        let contoursObservation = contourRequest.results as! [VNContoursObservation]
        let vnContours = contoursObservation.flatMap { contour in
            (0..<contour.contourCount).compactMap { try? contour.contour(at: $0) }
        }
        let d33 = vnContours.map { ContourStruct(vnContour: $0).boundingBox }
        var flipBRect = d33.map{
            CGRect(x: $0.minX , y: 1-$0.minY-$0.height, width: $0.width, height: $0.height)}
        var sortedBRects = flipBRect.sorted { $0.area > $1.area }
        if sortedBRects.count > 3 {
            let croppBRect = sortedBRects[3]
            ViewController.Instance.paperBRect = sortedBRects[3]
            let pcropedImg = cropImages.instance.paperCropedImg(bRect:ViewController.Instance.paperBRect, oimg: originalImage)
            
            return (pcropedImg)
        }
        else {
            ViewController.Instance.somethingIsWrong = true
            return image
        }
    }
    
    func findFeetContours(_ image : UIImage) -> UIImage {
        let context = CIContext()
        var inputImage = CIImage.init(cgImage: image.cgImage!)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.revision = VNDetectContourRequestRevision1
        let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])
        try! requestHandler.perform([contourRequest])
        let contoursObservation = contourRequest.results as! [VNContoursObservation]
        let vnContours = contoursObservation.flatMap { contour in
            (0..<contour.contourCount).compactMap { try? contour.contour(at: $0) }
        }
        let d33 = vnContours.map { ContourStruct(vnContour: $0).boundingBox }
        var flipBRect = d33.map{
            CGRect(x: $0.minX , y: 1-$0.minY-$0.height, width: $0.width, height: $0.height)}
        var sortedBRects = flipBRect.sorted { $0.area > $1.area }
        if sortedBRects.count > 3 {
            let croppBRect = sortedBRects[3]
            ViewController.Instance.feetBRect = sortedBRects[3]
            let feetImage = drawBoundingBoxesBRect(on: image, boxes: sortedBRects[3], color: .red)
            return (feetImage)
        }
        else {
            ViewController.Instance.somethingIsWrong = true
            return image
        }
    }
    
    func drawBoundingBoxesBRect(on image: UIImage, boxes: CGRect, color: UIColor) -> UIImage  {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        let imageSize = image.size
        var box1 = CGRect(x:boxes.minX, y: boxes.minY, width: boxes.width, height: boxes.height)
        var rect = box1.applying(CGAffineTransform(scaleX: imageSize.width, y: imageSize.height))
        context.addRect(rect)
        context.strokePath()
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        Helper.instance.saveImage(image: result!, name: "FootBox")
        return result!
    }
}
