//
//  File.swift
//  
//
//  Created by Damiaan on 27/02/2020.
//

import XCTest
@testable import Evangelizo

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let session = URLSession(configuration: .default)

final class EvangelizoTests: XCTestCase {

	func testCanGetReadingsOfTheDay() {
		let expectation = XCTestExpectation(description: "download liturgical info for today")
		downloadLiturgicalInfo(session: session, priority: .normal) { result in
			switch result {
			case .success(let container):
				print(container.date, container.liturgicTitle)
				XCTAssertGreaterThan(container.liturgicTitle.count, 0)
				expectation.fulfill()
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		}

		wait(for: [expectation], timeout: 10.0)
	}

}
