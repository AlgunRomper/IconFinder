//
//  IconFinderTests.swift
//  IconFinderTests
//
//  Created by Algun Romper on 1/8/24.
//

import XCTest
@testable import IconFinder

final class IconFinderTests: XCTestCase {
    
    var iconSearchService: IconSearchService!
    private var mockData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        iconSearchService = IconSearchService()
        
        let json = """
                {
                    "icons": [
                        {
                            "icon_id": 1,
                            "tags": ["test"],
                            "raster_sizes": [
                                {
                                    "formats": [
                                        {
                                            "format": "png",
                                            "preview_url": "https://example.com/image.png",
                                            "download_url": "https://example.com/download.png"
                                        }
                                    ],
                                    "size_width": 100,
                                    "size_height": 100
                                }
                            ]
                        }
                    ]
                }
                """
        mockData = json.data(using: .utf8)
    }
    
    override func tearDownWithError() throws {
        iconSearchService = nil
        URLCache.shared.removeAllCachedResponses()
        try super.tearDownWithError()
    }
    
    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
    //testing cache image
    func testImageCaching() throws {
        let cacheManager = IconCacheManager.shared
        
        let testURL = "https://example.com/image.png"
        let testImage = UIImage(systemName: "star")
        
        cacheManager.setImage(testImage!, for: testURL)
        
        let cachedImage = cacheManager.image(for: testURL)
        
        XCTAssertEqual(cachedImage, testImage, "Cached image should match the saved image")
    }
    
    //testing of formatting tags
    func testTagFormatting() throws {
        let tags = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7", "tag8", "tag9", "tag10", "tag11"]
        
        let formattedTags = formatTags(tags: tags)
        let expectedTags = "tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10"
        
        XCTAssertEqual(formattedTags, expectedTags, "Tags should be formatted correctly")
    }
    
    private func formatTags(tags: [String]) -> String {
        return tags.prefix(10).joined(separator: ", ")
    }
    
    //testing saving to cache
    func testCacheSavingAndRetrieving() throws {
        let query = "test"
        
        let expectation = self.expectation(description: "Fetch icons from network and cache")
        
        iconSearchService.searchIcons(query: query) { icons, error in
            XCTAssertNotNil(icons, "Expected icons to be returned")
            XCTAssertNil(error, "Expected no error")
            
            // Проверяем, что данные кешируются
            let request = self.createRequest(query: query)
            let cachedResponse = URLCache.shared.cachedResponse(for: request)
            
            XCTAssertNotNil(cachedResponse, "Expected cached response to be available")
            
            if let data = cachedResponse?.data {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(IconResponse.self, from: data)
                    XCTAssertEqual(response.icons.count, 10, "Expected one icon in cached response")
                } catch {
                    XCTFail("Failed to decode cached data: \(error)")
                }
            } else {
                XCTFail("No data found in cached response")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    //test request from cache
    func testRetrieveFromCache() throws {
        let query = "test"
        
        let expectation = self.expectation(description: "Fetch icons from network and cache")
        
        iconSearchService.searchIcons(query: query) { _, _ in
            
            self.iconSearchService.searchIcons(query: query) { icons, error in
                XCTAssertNotNil(icons, "Expected icons to be returned")
                XCTAssertNil(error, "Expected no error")
                
                let request = self.createRequest(query: query)
                let cachedResponse = URLCache.shared.cachedResponse(for: request)
                
                XCTAssertNotNil(cachedResponse, "Expected cached response to be available")
                
                if let data = cachedResponse?.data {
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(IconResponse.self, from: data)
                        XCTAssertEqual(response.icons.count, 10, "Expected one icon in cached response")
                    } catch {
                        XCTFail("Failed to decode cached data: \(error)")
                    }
                } else {
                    XCTFail("No data found in cached response")
                }
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    private func createRequest(query: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: "https://api.iconfinder.com/v4/icons/search") else {
            fatalError("Invalid URL")
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "type", value: "png"),
            URLQueryItem(name: "premium", value: "false")
        ]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Authorization": "Bearer \(iconSearchService.apiKey)"
        ]
        
        return request
    }
}
