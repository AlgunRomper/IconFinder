//
//  PhotoLibraryManager.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import Foundation
import UIKit
import Photos

class PhotoLibraryManager: NSObject {
    static let shared = PhotoLibraryManager()

    func writeToPhotoAlbum(image: UIImage) {
        print("save image start")
        let startTime = DispatchTime.now()
        
        DispatchQueue.global(qos: .background).async {
            if PHPhotoLibrary.authorizationStatus() == .denied || PHPhotoLibrary.authorizationStatus() == .restricted {
                let alert = AlertAccessViewController.shared
                alert.showAlert()
            } else {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveCompleted), nil)
            }
        }
        
        let endTime = DispatchTime.now()
        let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let milliseconds = Double(elapsedTime) / 1_000_000
        print("save image stop: \(milliseconds) ms")
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = AlertSaveSuccessViewController.shared
        alert.showAlert()
    }
}
