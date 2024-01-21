//
//  Date operators.swift
//  Daily Gospel
//
//  Created by Damiaan Dufaux on 05/08/2018.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation

let calendar = Calendar(identifier: .gregorian)

public struct DateTuple: Hashable {
	public let year: Int
	public let month: Int
	public let day: Int

	public init(from dateComponents: DateComponents) throws {
		guard let day = dateComponents.day else {
			throw ParsingError.unableToRetreiveCurrentDay
		}
		guard let month = dateComponents.month else {
			throw ParsingError.unableToRetreiveCurrentMonth
		}
		guard let year = dateComponents.year else {
			throw ParsingError.unableToRetreiveCurrentYear
		}
		self.day = day
		self.month = month
		self.year = year
	}

	public var components: DateComponents {
		DateComponents(
			calendar: .init(identifier: .gregorian),
			year: year, month: month, day: day
		)
	}
    
    public static var today: Self {
        try! DateTuple(from: Date().components)
    }
}

extension Date {
	/// Adds one unit to `date` or leaves the date unchanged if not possible
	public static func +=(date: inout Date, addition: (amount: Int, unit: Calendar.Component)) {
		date = calendar.date(byAdding: addition.unit, value: addition.amount, to: date) ?? date
	}

	/// Subtracts one unit from `date` or leaves the date unchanged if not possible
	public static func -=(date: inout Date, subtraction: (amount: Int, unit: Calendar.Component)) {
		date = calendar.date(byAdding: subtraction.unit, value: -subtraction.amount, to: date) ?? date
	}

	public var components: DateComponents {
		return calendar.dateComponents([.day, .month, .year], from: self)
	}
}
