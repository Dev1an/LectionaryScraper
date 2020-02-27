import XCTest

import DionysiusTests
import EvangelizoTests
import UsccbTests

var tests = [XCTestCaseEntry]()
tests += DionysiusTests.__allTests()
tests += EvangelizoTests.__allTests()
tests += UsccbTests.__allTests()

XCTMain(tests)
