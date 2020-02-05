import XCTest
@testable import HMassTexts

final class HMassTextsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HMassTexts().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
