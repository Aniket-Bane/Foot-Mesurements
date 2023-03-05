//
//  Helper.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 24/02/23.
//

import Foundation
import SVProgressHUD
import UIKit

class Helper {
    
    static var instance = Helper()
    
    func showLoader() {
        OperationQueue.main.addOperation{
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.show()
        }
    }
    
    func hideLoader() {
        OperationQueue.main.addOperation {
            SVProgressHUD.dismiss()
        }
    }
    
    func saveImage(image: UIImage , name : String) {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(saveTime())\(name).png")!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteImges() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "png" {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  { print(error) }
    }
    
    func saveTime () -> String {
        let today = Date()
        let year = (Calendar.current.component(.year, from: today))
        let month = (Calendar.current.component(.month, from: today))
        let date = (Calendar.current.component(.day, from: today))
        let hours = (Calendar.current.component(.hour, from: today))
        let minutes = (Calendar.current.component(.minute, from: today))
        let secounds = (Calendar.current.component(.second, from: today))
        let time: String = "\(date)-\(month)-\(year),\(hours):\(minutes):\(secounds)"
        return time
    }
}
