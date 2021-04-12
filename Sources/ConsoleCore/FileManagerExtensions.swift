//
//  File.swift
//  
//
//  Created by Bruce Wade on 2021-04-09.
//

import Foundation

public extension FileManager {
    static var documentsDirectoryURL: URL {
      `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
