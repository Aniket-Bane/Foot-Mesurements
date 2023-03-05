//
//  croppImage.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 28/02/23.
//  Copyright © 2023 Jayven Nhan. All rights reserved.
//

import Foundation
import UIKit

class cropImages {
    static var instance = cropImages()
    
    func paperCropedImg(bRect: CGRect, oimg: UIImage) -> UIImage {
        let Oimage = oimg
        let x = bRect.origin.x
        let y = bRect.origin.y
        let w = bRect.size.width
        let h = bRect.size.height
        
        let CRect = CGRect(x: x, y: y, width: w, height: h).applying(CGAffineTransform(scaleX: oimg.size.width, y: oimg.size.height))
        
        let pcropedImg = Oimage.cgImage!.cropping(to: CRect)
        let pcropedUIImage = UIImage(cgImage: pcropedImg!)
        return (pcropedUIImage)
    }
    
    
    func croppedImage(bRect: CGRect ,image : UIImage ) -> UIImage {
        let pcropedUIImage = image
        let x = bRect.origin.x
        let y = bRect.origin.y
        let x1 = CGFloat(0)
        let y1 = CGFloat(0)
        let w1 = pcropedUIImage.size.width
        let h1 = pcropedUIImage.size.height
        let y2 = CGFloat(Double(h1)/10.0)
        let x2 = CGFloat(Double(w1)/10.0)
        
        let crop1Rect = CGRect(x: x1 + x2, y: y1 + y2, width: w1 - 2 * x2, height: h1 - 2 * y2)
        var FWidth = crop1Rect.size.width
        var FHeight = crop1Rect.size.height
        ViewController.Instance.FootWidth = Double(FWidth)
        ViewController.Instance.footHeight = Double(FHeight)
        
        let crop1ImgRef = pcropedUIImage.cgImage?.cropping(to: crop1Rect)
        let crop1Img = UIImage(cgImage: crop1ImgRef!)
        
        let ix = CGFloat(x) + x2
        let iy = CGFloat(y) + y2
        let iw = crop1Img.size.width
        let ih = crop1Img.size.height
        let croppedImgRef = pcropedUIImage.cgImage?.cropping(to: CGRect(x: ix, y: iy, width: iw, height: ih))
        let croppedImg = UIImage(cgImage: croppedImgRef!)
        return croppedImg
    }
    
 
}
