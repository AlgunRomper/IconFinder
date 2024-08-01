//
//  File.swift
//  IconFinderTests
//
//  Created by Algun Romper on 1/8/24.
//

import XCTest

class MockURLProtocol: URLProtocol {
    static var testData: Data?
    static var testResponse: HTTPURLResponse?
    static var testError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let data = MockURLProtocol.testData {
            self.client?.urlProtocol(self, didLoad: data)
        }
        if let response = MockURLProtocol.testResponse {
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = MockURLProtocol.testError {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
}
