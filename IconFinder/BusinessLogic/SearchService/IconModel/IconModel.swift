//
//  IconModel.swift
//  IconFinder
//
//  Created by Algun Romper on 1/8/24.
//

import Foundation

struct IconResponse: Codable {
    let icons: [IconModel]
}

struct IconModel: Codable {
    let icon_id: Int
    let tags: [String]
    let raster_sizes: [RasterSize]
}

struct RasterSize: Codable {
    let formats: [Format]
    let size_width: Int
    let size_height: Int
}

struct Format: Codable {
    let format: String
    let preview_url: String
    let download_url: String
}
