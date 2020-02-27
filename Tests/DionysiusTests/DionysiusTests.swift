import XCTest
@testable import DionysiusParochieReadings

final class LectionaryScraperTests: XCTestCase {
    func testFindAtLeastOneDay() throws {
		print("downloading calendar from Dionysiusparochie.nl")
		let calendar = try downloadCalendar()
		XCTAssertGreaterThan(calendar.count, 0)
		print("found", calendar.count, "dates")
    }

    static var allTests = [
        ("testFindAtLeastOneDay", testFindAtLeastOneDay),
    ]
}
