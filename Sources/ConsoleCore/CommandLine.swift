//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-09.
//

import Foundation

public enum ArgumentOption: String {
    case url = "u"
    case top = "t"
    case help = "h"
    case unknown
    
    public init(value: String) {
        switch value {
        case "u": self = .url
        case "t": self = .top
        case "h": self = .help
        default: self = .unknown
        }
    }
}

public final class ConsoleTool {
    private let arguments: [String]
    public var urlCache: ShortURLCache
    private var session: URLSession
    
    public init(arguments: [String] = CommandLine.arguments, urlCache: ShortURLCache = ShortURLCache(), session: URLSession = URLSession.shared) {
        self.arguments = arguments
        self.urlCache = urlCache
        self.session = session
    }
    
    public func run() throws {
        if arguments.count > 1 {
            // Static mode
            staticMode()
        } else {
            // Interactive mode
            interactiveMode()
        }
    }
    
    public func staticMode() {
        let argument = arguments[1]
        let index = argument.index(argument.startIndex, offsetBy: 1)
        let option = getOption(String(argument[index...]))
        
        switch option {
        
        case .url:
//            print("Need to get/cache url")
            if arguments.count > 2 {
                let destination = arguments[2]
                // Check the URL is valid
                if let url = URL(string: destination), url.host != nil && url.scheme != nil {
                    // URL Exist in cache
                    if let url = urlCache.getShortURL(for: url) {
                        print("(cached) \(url)")
                    } else {
                        let tinyURLClient = TinyURLClient(baseURL: URL(string: "http://tinyurl.com")!, session: session, responseQueue: nil)
                        var waitingForResponse = true
                        tinyURLClient.getShortURL(for: url) { [weak self] result in
                            switch result {
                            case .failure(let error):
                                print(error)
                                
                            case .success(let shortURL):
                                self?.urlCache.addUrl(long: url, short: shortURL)
                                print(shortURL)
                            }
                            waitingForResponse = false
                        }
                        // loop here until the getShortURL has completed, otherwise the app will terminate
                        // before the request is finished.
                        while waitingForResponse {}
                    }
                } else {
                    print("Please enter a valid URL. (including the schema http/https)")
                }
            } else {
                print("Missing required url usage: URLShortener -u http://example.com")
            }
        case .top:
            var limit = 3
            
            if arguments.count > 2, let newLimit = Int(arguments[2]) {
                limit = newLimit
            }
            
            print("Top \(limit) hits")
            let ordered = urlCache.orderByMostHits(limit: limit)
            
            for cached in ordered {
                print("\(cached.long) - \(cached.short) count: \(cached.accessCount)")
            }
        case .help:
            print("Welcome to URLShortener.\n")
            print("""
                OVERVIEW: Shortens the provided URL using http://tinyurl.com \
                Everytime a URL is required it with get the URL from Cache or add it to cache if it doesn't exist. Also a hits counter \
                will increase.

                Instructions running the application without any options starts the interactive mode. (To Quit type q + <Enter>)

                OPTIONS:
                    -u <url>        Will get the cached shortened url if it exists otherwise will generate one and cache it.
                                    USAGE:  urlshortener -u http://example.com

                    -t <limit>      Will return the top most used URLs in the cache. Limit is the number of urls to return default is 3 (optional).
                                    USAGE:  urlshortener -t 3

                    -h              Prints out these help instructions.
                                    USAGE:  urlshortener -h
                
                """)
        case .unknown:
            print("Unknown option for instructions use: `urlshortener -h`")
        }
    }
    
    public func interactiveMode() {
        
        print("This program will shorten and cache a valid url.")
        print("Type 'q' to quit.")
        var shouldQuit = false
        var isGeneratingURL = false
        let tinyURLClient = TinyURLClient(baseURL: URL(string: "http://tinyurl.com")!, session: session, responseQueue: nil)
        while !shouldQuit {
            if !isGeneratingURL {
                print("\nEnter URL: ", terminator: "")
                let urlInput = readLine() ?? ""
                
                if urlInput.lowercased() == "q" {
                    shouldQuit = true
                } else {
                    // Check the URL is valid
                    if let url = URL(string: urlInput), url.host != nil && url.scheme != nil {
                        // URL Exist in cache
                        if let url = urlCache.getShortURL(for: url) {
                            print("(cached) \(url)")
                        } else {
                            isGeneratingURL = true
                            tinyURLClient.getShortURL(for: url) { [weak self] result in
                                switch result {
                                case .failure(let error):
                                    print(error)
                                    
                                case .success(let shortURL):
                                    self?.urlCache.addUrl(long: url, short: shortURL)
                                    print(shortURL)
                                }
                                isGeneratingURL = false
                            }
                        }
                    } else {
                        print("Please enter a valid URL. (including the schema http/https)")
                    }
                }
            }
        }
        
    }
    
    public func getOption(_ option: String) -> ArgumentOption {
        return ArgumentOption(value: option)
    }
}
