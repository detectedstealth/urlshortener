//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-10.
//

import Foundation
import XCTest
import ConsoleCore

final class CommandLineTests: XCTestCase {
    let fileName = "ShortenedCacheTest.json"
    var urlCache: ShortURLCache!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        urlCache = ShortURLCache(cacheFileName: fileName, relativeTo: FileManager.default.temporaryDirectory)
        mockSession = MockURLSession()
    }
    
    override func tearDown() {
        // Remove cached file.
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: URL(fileURLWithPath: fileName, relativeTo: fileManager.temporaryDirectory))
        } catch let error {
            print(error)
        }
        mockSession = nil
        super.tearDown()
    }

    func testAgumentOptions() {
        XCTAssertEqual(ArgumentOption(value: "u"), ArgumentOption.url)
        XCTAssertEqual(ArgumentOption(value: "t"), ArgumentOption.top)
        XCTAssertEqual(ArgumentOption(value: "h"), ArgumentOption.help)
        XCTAssertEqual(ArgumentOption(value: "x"), ArgumentOption.unknown)
    }
    
    func testCanCreateConsoleTool() {
        let consoleTool = ConsoleTool(arguments: [], urlCache: urlCache)
        XCTAssertEqual(consoleTool.urlCache, urlCache)
    }
    
    func testGetOption() {
        let consoleTool = ConsoleTool(arguments: [], urlCache: urlCache)
        XCTAssertEqual(consoleTool.getOption("u"), ArgumentOption.url)
        XCTAssertEqual(consoleTool.getOption("t"), ArgumentOption.top)
        XCTAssertEqual(consoleTool.getOption("h"), ArgumentOption.help)
        XCTAssertEqual(consoleTool.getOption("x"), ArgumentOption.unknown)
    }
}
