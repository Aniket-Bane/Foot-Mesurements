//
//  Phase3.swift
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
class edgeDetection {
    
    static let instace = edgeDetection()
    
    func outerEdgeDetction( _ image: UIImage ) -> UIImage{
        let edgeWorkFilter = CIFilter(name: "CIEdgeWork")
        edgeWorkFilter?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        edgeWorkFilter?.setValue(1, forKey: "inputRadius")
        let outputImage = (edgeWorkFilter?.outputImage)!
        
        let filter = CIFilter(name: "CIMorphologyMaximum")
        filter!.setValue(outputImage, forKey: kCIInputImageKey)
        filter!.setValue(3, forKey: kCIInputRadiusKey)
        let outputCIImage = filter?.outputImage
        let context = CIContext(options: nil)
        let outputCGImage = context.createCGImage(outputCIImage!, from: outputCIImage!.extent)
        
        let inputImage = CIImage(cgImage: outputCGImage!)
        let erosionFilter = CIFilter(name: "CIMorphologyMinimum")!
        erosionFilter.setValue(inputImage, forKey: kCIInputImageKey)
        erosionFilter.setValue(2, forKey: kCIInputRadiusKey)
        let erosionoOutputImage = erosionFilter.outputImage
        let erosionContext = CIContext(options: nil)
        let erosionOutputCGImage = erosionContext.createCGImage(erosionoOutputImage!, from: erosionoOutputImage!.extent)
        let finalImage = UIImage(cgImage: erosionOutputCGImage!)
        return finalImage
    }
}
    
