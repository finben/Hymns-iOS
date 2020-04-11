//
//  XCTFailSwizzler.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 3/11/20.
//

import Foundation
import XCTest

public protocol TestFailer {
  func fail(message: String, file: StaticString, line: UInt)
}

public func swizzleTestFailer(_ newTestFailer: TestFailer) {
  if Thread.isMainThread {
    testFailer = newTestFailer
  } else {
    DispatchQueue.main.sync { testFailer = newTestFailer }
  }
}

public func MKBFail(_ message: String, file: StaticString = #file, line: UInt = #line) {
  testFailer.fail(message: message, file: file, line: line)
}

// MARK: - Internal

private class StandardTestFailer: TestFailer {
  func fail(message: String, file: StaticString, line: UInt) {
    XCTFail(message, file: file, line: line)
  }
}

private var testFailer: TestFailer = StandardTestFailer()
