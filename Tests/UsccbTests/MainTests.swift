//
//  File.swift
//  
//
//  Created by Damiaan on 27/02/2020.
//

import XCTest
@testable import UsccbReadings

class UsccbTests: XCTestCase {

	func testCanDownloadReadingsOfToday() throws {
		XCTAssertGreaterThan(try downloadReadings().count, 0) 
	}

}
