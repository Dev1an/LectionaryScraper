//
//  File.swift
//  
//
//  Created by Damiaan on 14/02/2020.
//

import HMassTexts
import Foundation
import Kanna

func url(for date: DateTuple) -> URL {
	let dateString = date.month.pad2 + date.day.pad2 + String(String(date.year).suffix(2))
	return URL(string: "http://www.usccb.org/bible/readings/\(dateString).cfm")!
}

public enum ParseError: Swift.Error {
	case contentNotFound
	case dateNotFound
	case readingsNotFound
}

public func downloadReadings(for date: DateTuple) throws -> [StyledTextSegment] {
	let html = try HTML(url: url(for: date), encoding: .utf8)

	guard let contentElement = html.css(".readings").first else {
		throw ParseError.contentNotFound
	}

	guard let date = contentElement.css("h3").first?.xpath("child::node()").first?.normalizedText else {
		throw ParseError.dateNotFound
	}

	let readings = contentElement.css(".bibleReadingsWrapper")

	var readingsElements = [StyledTextSegment]()

	readingsElements.append(.liturgicalDate(date))

	func addChilds(of element: Kanna.XMLElement) {
		let tagName = element.tagName
		if tagName == "text", let text = element.normalizedText {
			if text.starts(with: "R.") || text.range(of: #"R.\s+(.+)"#) != nil {
				readingsElements.append(.responseTitle)
			} else {
				readingsElements.append(.text(text))
			}
		} else if tagName == "h4", let text = element.normalizedText {
			readingsElements.append(.title(text))
		} else if tagName == "br" && readingsElements.last?.isTitle == false {
			readingsElements.append(.lineBreak)
		} else if element.className?.contains("box-yellow") ?? false {
			// skip
		} else {
			for child in element.xpath("child::node()") {
				addChilds(of: child)
			}
			if tagName == "p" && readingsElements.last?.isTitle == false {
				readingsElements.append(.paragraphBreak)
			}
		}
	}

	for reading in readings {
		addChilds(of: reading)
	}

	return readingsElements
}

extension Kanna.XMLElement {
	var normalizedText: String? {
		if case .String(let text) = xpath("normalize-space(.)"), !text.isEmpty {
			return text
		} else {
			return nil
		}
	}
}
