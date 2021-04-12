//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-10.
//

import Foundation

public class TinyURLClient {
    public let baseURL: URL
    public let session: URLSession
    public let responseQueue: DispatchQueue?
//    static let endpoint = "http://tinyurl.com/api-create.php"
    
    public enum TinyURLError: Error {
        case noData
        case invalidURLEntered
        case parsingError
    }
    
    public init(baseURL: URL, session: URLSession, responseQueue: DispatchQueue?) {
        self.baseURL = baseURL
        self.session = session
        self.responseQueue = responseQueue
    }
    
    @discardableResult
    public func getShortURL(for long: URL, completion: @escaping (Result<URL, TinyURLClient.TinyURLError>) -> Void) -> URLSessionDataTask {
        
        let createURL = URL(string: "api-create.php", relativeTo: baseURL)!
        var urlComponents = URLComponents(url: createURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "url", value: long.absoluteString)
        ]
        let task = session.dataTask(with: urlComponents.url!) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil, let data = data, let value = String(data: data, encoding: .utf8) else {
                guard let responseQueue = self.responseQueue else {
                    completion(.failure(.noData))
                    return
                }
                responseQueue.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            guard let responseQueue = self.responseQueue else {
                if value == "Error" {
                    completion(.failure(.invalidURLEntered))
                } else {
                    if let shortURL = URL(string: value) {
                        completion(.success(shortURL))
                    } else {
                        completion(.failure(.parsingError))
                    }
                }
                return
            }
            responseQueue.async {
                if value == "Error" {
                    completion(.failure(.invalidURLEntered))
                } else {
                    if let shortURL = URL(string: value) {
                        completion(.success(shortURL))
                    } else {
                        completion(.failure(.parsingError))
                    }
                }
            }
            
        }
        task.resume()
        return task
    }
}


