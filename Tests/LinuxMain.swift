import XCTest

import gattserverTests

var tests = [XCTestCaseEntry]()
tests += gattserverTests.allTests()
XCTMain(tests)