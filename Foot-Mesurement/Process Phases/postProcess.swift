//
//  Phase5.swift
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


class postProcess {
    static let instace = postProcess()


    func calcFeetSize (pcropedImg: UIImage, oimg : UIImage , fboundRect: CGRect) -> (String , String) {
        let x1 = Double(fboundRect.origin.x)
        let y1 = Double(fboundRect.origin.y)
        
        let fboundRect2 = CGRect(x: fboundRect.origin.x,
                           y: fboundRect.origin.y,
                           width: fboundRect.size.width,
                                 height: fboundRect.size.height).applying(CGAffineTransform(scaleX: (oimg.size.width), y: oimg.size.height))
        
        let fhr = Double(fboundRect2.size.height)
        let fwr = Double(fboundRect2.size.width)
        
        let w1 = Double(pcropedImg.size.width)
        let h1 = Double(pcropedImg.size.height)
        
        let y2 = h1 / 10
        let x2 = w1 / 10
        
        var bufferY = 0.0
        var bufferX = 0.0
        
        bufferY = (y2 / 2.80)

        let fh = Double((fhr) + y2 + bufferY )
        let fw = Double((fwr) + x2 )
        
        let ph = Double(pcropedImg.size.height)
        let pw = Double(pcropedImg.size.width)

        
        let opw = 210.0
        let oph = 300.0
        
        var ofsh = 0.0
        var ofsw = 0.0
        
        var CM = 0.0
        var CM2 = 0.0
        
        var Height = ""
        var Width = ""
        
        var roundOffH = 0.0
        var roundOffW = 0.0
        
        ofsh = (oph / ph) * fh
        CM = (ofsh / 10)
        
        ofsw = (opw / pw) * fw
        CM2 = (ofsw / 10)
        
            
        roundOffH = CM.rounded()
        Height = String(format: "%.1f", CM)
        
        roundOffW = CM2.rounded()
        Width = String(format: "%.1f", CM2)
        
        return (Height , Width)
    }
}
