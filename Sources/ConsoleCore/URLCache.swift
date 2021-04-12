//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-09.
//

import Foundation

public struct ShortURL: Codable {
    public let long: URL
    public let short: URL
    public var accessCount = 1
    
    public init(long: URL, short: URL, accessCount: Int = 1) {
        self.long = long
        self.short = short
        self.accessCount = accessCount
    }
}

extension ShortURL: Equatable {}

open class ShortURLCache {
    private let cacheJSONURL: URL!
    
    public private(set) var shortenedURLs: [ShortURL] = [] {
        didSet {
            saveCache()
        }
    }
    
    public init(cacheFileName: String = "ShortenedCache.json", relativeTo: URL = FileManager.documentsDirectoryURL) {
        self.cacheJSONURL = URL(fileURLWithPath: cacheFileName, relativeTo: relativeTo)
        loadCache()
    }
    
    public func loadCache() {
        guard FileManager.default.fileExists(atPath: cacheJSONURL.path) else {
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let cachedData = try Data(contentsOf: cacheJSONURL)
            shortenedURLs = try decoder.decode([ShortURL].self, from: cachedData)
        } catch let error {
            print(error)
        }
    }
    
    public func saveCache() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let cachedData = try encoder.encode(shortenedURLs)
            try cachedData.write(to: cacheJSONURL, options: .atomicWrite)
        } catch let error {
            print(error)
        }
    }
    
    public func getCached(long: URL) -> (index: Int, cached: ShortURL)? {
        if let index = shortenedURLs.firstIndex(where: { $0.long == long }) {
            return (index, shortenedURLs[index])
        }
        return nil
    }
    
    public func addUrl(long: URL, short: URL) {
        if getCached(long: long) == nil {
            let shortURL = ShortURL(long: long, short: short)
            shortenedURLs.append(shortURL)
        }
    }
    
    public func getShortURL(for long: URL) -> URL? {
        if let cachedURL = getCached(long: long) {
            // Increase the cache hit count
            shortenedURLs[cachedURL.index].accessCount += 1
            return cachedURL.cached.short
        }
        // Need to call tinyurl to generate url
        return nil
        
    }
    
    public func orderByMostHits(limit: Int = 3) -> [ShortURL] {
        Array(shortenedURLs.sorted(by: { $0.accessCount > $1.accessCount }).prefix(limit))
    }
}

extension ShortURLCache: Equatable {
    public static func == (lhs: ShortURLCache, rhs: ShortURLCache) -> Bool {
        lhs.shortenedURLs == rhs.shortenedURLs
    }
}
