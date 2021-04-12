//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-11.
//

import Foundation
import ConsoleCore

class MockURLSession: URLSession {
  var queue: DispatchQueue? = nil
  
  func givenDispatchQueue() {
    queue = DispatchQueue(label: "com.DogPatchTests.MockSession")
  }
  
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return MockURLSessionDataTask(completionHandler: completionHandler, url: url, queue: queue)
  }
}

class MockURLSessionDataTask: URLSessionDataTask {
  var completionHandler: (Data?, URLResponse?, Error?) -> Void
  var url: URL
  var calledResume = false
  
  init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, url: URL, queue: DispatchQueue?) {
    if let queue = queue {
      self.completionHandler = { data, response, error in
        queue.async {
          completionHandler(data, response, error)
        }
      }
    } else {
      self.completionHandler = completionHandler
    }
    
    self.url = url
  }
  
  override func resume() {
    calledResume = true
  }
}
