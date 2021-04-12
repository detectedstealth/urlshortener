//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-10.
//

import Foundation
import XCTest
import ConsoleCore

final class URLCacheTests: XCTestCase {
    let fileName = "ShortenedCacheTest.json"
    var urlCache: ShortURLCache!
    
    override func setUp() {
        urlCache = ShortURLCache(cacheFileName: fileName, relativeTo: FileManager.default.temporaryDirectory)
    }
    
    override func tearDown() {
        // Remove cached file.
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: URL(fileURLWithPath: fileName, relativeTo: fileManager.temporaryDirectory))
        } catch let error {
            print(error)
        }
    }
    
    func testCreateShortURL() {
        var shortURL = ShortURL(long: URL(string: "http://example.com")!, short: URL(string: "https://tinyurl.com/y2vayt2q")!)
        
        XCTAssertEqual(shortURL.long.absoluteString, "http://example.com")
        XCTAssertEqual(shortURL.short.absoluteString, "https://tinyurl.com/y2vayt2q")
        XCTAssertEqual(shortURL.accessCount, 1)
        
        shortURL.accessCount += 1
        XCTAssertEqual(shortURL.accessCount, 2)
    }
    
    func testCanSaveToCache() {
        XCTAssertEqual(urlCache.shortenedURLs.count, 0)
        
        urlCache.addUrl(long: URL(string: "http://example1.com")!, short: URL(string: "http://tinyurl.com/example1.com")!)
        
        urlCache.addUrl(long: URL(string: "http://example2.com")!, short: URL(string: "http://tinyurl.com/example2.com")!)
        
        XCTAssertEqual(urlCache.shortenedURLs.count, 2)
    }
    
    func testCanLoadCache() {
        XCTAssertEqual(urlCache.shortenedURLs.count, 0)
        
        urlCache.addUrl(long: URL(string: "http://example1.com")!, short: URL(string: "http://tinyurl.com/example1.com")!)
        
        urlCache.loadCache()
        
        XCTAssertEqual(urlCache.shortenedURLs.count, 1)
    }
    
    func testGetCached() {
        // Cache is currently empty this shouldn't exist yet.
        XCTAssertNil(urlCache.getCached(long: URL(string: "http://example1.com")!))
        
        urlCache.addUrl(long: URL(string: "http://example1.com")!, short: URL(string: "http://tinyurl.com/example1.com")!)
        
        let cachedResult = urlCache.getCached(long: URL(string: "http://example1.com")!)
        XCTAssertNotNil(cachedResult)
        XCTAssertEqual(cachedResult?.cached.long.absoluteString, "http://example1.com")
        XCTAssertEqual(cachedResult?.cached.short.absoluteString, "http://tinyurl.com/example1.com")
        XCTAssertEqual(urlCache.shortenedURLs.count, 1)
    }
    
    func testGetShortURL() {
        // Cache is currently empty this shouldn't exist yet.
        XCTAssertNil(urlCache.getShortURL(for: URL(string: "http://example1.com")!))
        
        urlCache.addUrl(long: URL(string: "http://example1.com")!, short: URL(string: "http://tinyurl.com/example1.com")!)
        
        let shortURL = urlCache.getShortURL(for: URL(string: "http://example1.com")!)
        XCTAssertNotNil(shortURL)
        XCTAssertEqual(shortURL?.absoluteString, "http://tinyurl.com/example1.com")
        
        // Test to make sure the access counts are correctly calculated
        // Should be 2 initial add sets it to 1 and the get increments it.
        XCTAssertEqual(urlCache.shortenedURLs.first?.accessCount, 2)
        
        _ = urlCache.getShortURL(for: URL(string: "http://example1.com")!)
        XCTAssertEqual(urlCache.shortenedURLs.first?.accessCount, 3)
    }
    
    func testOrderByMostHits() {
        // Cache is empty.
        XCTAssertEqual(urlCache.orderByMostHits().count, 0)
        
        // Add a few URLs which will all default to accessed count of 1
        urlCache.addUrl(long: URL(string: "http://example1.com")!, short: URL(string: "http://tinyurl.com/example1.com")!)
        urlCache.addUrl(long: URL(string: "http://example2.com")!, short: URL(string: "http://tinyurl.com/example2.com")!)
        urlCache.addUrl(long: URL(string: "http://example3.com")!, short: URL(string: "http://tinyurl.com/example3.com")!)
        urlCache.addUrl(long: URL(string: "http://example4.com")!, short: URL(string: "http://tinyurl.com/example4.com")!)
        
        // Lets get the short URLS so they will return in reverse order.
        _ = urlCache.getShortURL(for: URL(string: "http://example4.com")!)
        _ = urlCache.getShortURL(for: URL(string: "http://example4.com")!)
        _ = urlCache.getShortURL(for: URL(string: "http://example4.com")!)
        
        _ = urlCache.getShortURL(for: URL(string: "http://example3.com")!)
        _ = urlCache.getShortURL(for: URL(string: "http://example3.com")!)
        
        _ = urlCache.getShortURL(for: URL(string: "http://example2.com")!)
        
        // Default limit is 3
        var orderedByHits = urlCache.orderByMostHits()
        XCTAssertEqual(orderedByHits.count, 3)
        
        // Make sure example4 is the first in the list
        XCTAssertEqual(orderedByHits.first?.long, URL(string: "http://example4.com")!)
        XCTAssertEqual(orderedByHits[2].long, URL(string: "http://example2.com")!)
        
        // Get back all 4 results
        orderedByHits = urlCache.orderByMostHits(limit: 4)
        XCTAssertEqual(orderedByHits.count, 4)
        XCTAssertEqual(orderedByHits.first?.long, URL(string: "http://example4.com")!)
        XCTAssertEqual(orderedByHits.last?.long, URL(string: "http://example1.com")!)
    }
    
}
