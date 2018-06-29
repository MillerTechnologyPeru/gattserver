import XCTest
@testable import gattserver

final class gattserverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(gattserver().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
