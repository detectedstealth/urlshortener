//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-10.
//

import Foundation
import XCTest
import ConsoleCore

final class FileManagerExtentionTests: XCTestCase {
    
    func testUsersDocumentExtentionExists() {
        XCTAssert(FileManager.documentsDirectoryURL.lastPathComponent == "Documents")
    }
}
