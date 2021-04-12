//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-11.
//

import Foundation
import XCTest
import ConsoleCore

class NetworkTests: XCTestCase {
    var baseURL: URL!
    var mockSession: MockURLSession!
    var sut: TinyURLClient!
    var getShortURL: URL {
        let createURL = URL(string: "api-create.php", relativeTo: baseURL)!
        var urlComponents = URLComponents(url: createURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "url", value: "http://test.com")
        ]
        return urlComponents.url!
    }
    
    override func setUp() {
        super.setUp()
        
        baseURL = URL(string: "http://example.com")!
        mockSession = MockURLSession()
        sut = TinyURLClient(baseURL: baseURL, session: mockSession, responseQueue: nil)
    }
    
    override func tearDown() {
        baseURL = nil
        mockSession = nil
        super.tearDown()
    }
    
    func whenGetShort(data: Data? = nil, statusCode: Int = 200, error: TinyURLClient.TinyURLError? = nil) -> (calledCompletion: Bool, short: URL?, error: TinyURLClient.TinyURLError?) {
        
        let response = HTTPURLResponse(url: getShortURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        
        var calledCompletion = false
        var receivedShort: URL? = nil
        var receivedError: TinyURLClient.TinyURLError? = nil
        
        let mockTest = sut.getShortURL(for: URL(string: "http://test.com")!) { result in
            calledCompletion = true
            
            switch result {
            case .failure(let error):
                receivedError = error
                
            case .success(let url):
                receivedShort = url
            }
        } as! MockURLSessionDataTask
        
        mockTest.completionHandler(data, response, error)
        return (calledCompletion, receivedShort, receivedError)
    }
    
    func verifyGetShortDispatchedToMain(data: Data? = nil, statusCode: Int = 200, error: TinyURLClient.TinyURLError? = nil, line: UInt = #line) {
        mockSession.givenDispatchQueue()
        sut = TinyURLClient(baseURL: baseURL, session: mockSession, responseQueue: .main)
        
        let expectation = self.expectation(description: "Completion wasn't called")
        
        var thread: Thread!
        let mockTest = sut.getShortURL(for: URL(string: "http://test.com")!) { result in
            thread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionDataTask
        
        let response = HTTPURLResponse(url: getShortURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        mockTest.completionHandler(data, response, error)
        
        waitForExpectations(timeout: 0.2) { (_) in
            XCTAssertTrue(thread.isMainThread, line: line)
        }
    }
    
    func testInitSetsBaseURL() {
        XCTAssertEqual(sut.baseURL, baseURL)
    }
    
    func testInitSetsSession() {
        XCTAssertEqual(sut.session, mockSession)
    }
    
    func testInitSetsResponseQueue() {
        let responseQueue = DispatchQueue.main
        
        sut = TinyURLClient(baseURL: baseURL, session: mockSession, responseQueue: responseQueue)
        XCTAssertEqual(sut.responseQueue, responseQueue)
    }
    
    func testGetShortURLCallsExpectedURL() {
        let mockTest = sut.getShortURL(for: URL(string: "http://test.com")!) { _ in } as! MockURLSessionDataTask
        
        XCTAssertEqual(mockTest.url, getShortURL)
    }
    
    func testGetShortCallsResumeOnTask() {
        let mockTest = sut.getShortURL(for: URL(string: "http://test.com")!) { _ in } as! MockURLSessionDataTask
        
        XCTAssertTrue(mockTest.calledResume)
    }
    
    func testGetShortGivenResponseStatusCode500CallsCompletion() {
        let result = whenGetShort(statusCode: 500)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.short)
        XCTAssertTrue(result.error == TinyURLClient.TinyURLError.noData)
    }
    
    func testGetShortGivenErrorCallsCompletionWithError() throws {
        let expectedError = TinyURLClient.TinyURLError.noData
        
        let result = whenGetShort(error: expectedError)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.short)
        
        let actualError = try XCTUnwrap(result.error as TinyURLClient.TinyURLError?)
        XCTAssertEqual(actualError, expectedError)
    }
    
    func testGetShortGivenValidDataCallsCompletionWithShort() throws {
        let data = String("http://tinyurl.com/test.com").data(using: .utf8)
        let result = whenGetShort(data: data)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertEqual(result.short, URL(string: "http://tinyurl.com/test.com"))
        XCTAssertNil(result.error)
    }
    
    func testGetShortGivenErrorStringResponseCallsCompletionWithError() throws {
        let data = String("Error").data(using: .utf8)
        let result = whenGetShort(data: data)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.short)
        
        let actualError = try XCTUnwrap(result.error as TinyURLClient.TinyURLError?)
        XCTAssertEqual(actualError, TinyURLClient.TinyURLError.invalidURLEntered)
    }
    
    func testGetShortGivenUnexpectedDataString() throws {
        let data = String("").data(using: .utf8)
        let result = whenGetShort(data: data)
        
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.short)
        
        let actualError = try  XCTUnwrap(result.error as TinyURLClient.TinyURLError?)
        XCTAssertEqual(actualError, TinyURLClient.TinyURLError.parsingError)
    }
    
    func testGetShortGivenHTTPStatusErrorDispatchesToResponseQueue() {
        verifyGetShortDispatchedToMain(statusCode: 500)
    }
    
    func testGetShortGivenErrorDispatchesToResponseQueue() {
        let error = TinyURLClient.TinyURLError.noData
        verifyGetShortDispatchedToMain(error: error)
    }
    
    func testGetShort_GivenGoodResponseDispatchesToResponseQueue() throws {
        let data = String("http://tinyurl.com/test.com").data(using: .utf8)
        verifyGetShortDispatchedToMain(data: data)
    }
    
    func testGetShortErrorStringInResponseDispatchesToResponseQueue() throws {
        let data = String("Error").data(using: .utf8)
        verifyGetShortDispatchedToMain(data: data)
    }
    
    func testGetShortUnexpectedResponseDataDispatchesToResponseQueue() throws {
        let data = String("").data(using: .utf8)
        verifyGetShortDispatchedToMain(data: data)
    }
}
