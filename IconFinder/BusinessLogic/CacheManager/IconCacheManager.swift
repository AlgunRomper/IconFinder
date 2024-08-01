//
//  IconCache.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import Foundation
import UIKit

class IconCacheManager {
    static let shared = IconCacheManager()
    private init() {}

    private var cache = NSCache<NSString, UIImage>()

    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }

    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}
