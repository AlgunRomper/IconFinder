//
//  IconFinderUITests.swift
//  IconFinderUITests
//
//  Created by Algun Romper on 1/8/24.
//

import XCTest

final class IconFinderUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    //testing empty array text
    func testEmptyIconsMessage() throws {
        let emptyMessage = app.staticTexts["You haven't any icons results yet"]
        
        XCTAssertTrue(emptyMessage.exists, "The empty message should be displayed when there are no icons")
    }

    //testing visibility of Button
    func testSearchButtonVisibility() throws {
        let searchButton = app.buttons["searchButtonIdentifier"]
        XCTAssertTrue(searchButton.exists, "Search button should be visible on the screen")
    }
}
