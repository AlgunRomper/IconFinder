//
//  AlertViewController.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import UIKit

final class AlertAccessViewController: UIViewController {
    static var shared = AlertAccessViewController()
    
    func showAlert() {
        let alertController = UIAlertController(
            title: "Permission Required",
            message: "For save icons please give us access to your Library",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Open Settings", style: .cancel) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        if let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
