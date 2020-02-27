//
//  File.swift
//  
//
//  Created by Damiaan on 14/02/2020.
//

import LectionaryScraper
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

public struct RawContent {
	let content: Kanna.XMLElement

	public func liturgicalDate() throws -> String {
		guard let date = content.css("h3").first?.xpath("child::node()").first?.normalizedText else {
			throw ParseError.dateNotFound
		}
		return date
	}

	public func psalmResponse() -> String? {
		for title in content.css(".bibleReadingsWrapper h4") {
			if title.at_xpath("./text()[1]")?.normalizedText?.contains("Responsorial Psalm") ?? false {
				return title.parent!.css(".poetry strong").first?.normalizedText
			}
		}
		return nil
	}

	public func verseBeforeGospel() -> (content: String?, reference: String?) {
		for title in content.css(".bibleReadingsWrapper h4") {
			if let text = title.at_xpath("./text()[1]")?.normalizedText, text.contains("Verse Before The Gospel") || text.contains("Alleluia") {
				let verse: String?
				let reference: String?
				if let elements = title.parent!.css(".poetry p").first?.xpath("./text()"), elements.count > 0 {
					verse = elements.filter { element in
						let trimmed = element.normalizedText?.trimmingCharacters(in: .whitespacesAndNewlines)
						return trimmed != "R." && trimmed != "Alleluia, alleluia."
					}
					.compactMap { $0.normalizedText }
					.joined(separator: "\n")
				} else {
					verse = nil
				}
				if let referenceText = title.css("a[href]").first?.normalizedText {
					reference = referenceText
				} else {
					reference = nil
				}
				return (verse, reference)
			}
		}
		return (nil, nil)
	}
}

public func rawContent(for date: DateTuple) throws -> RawContent {
	let html = try HTML(url: url(for: date), encoding: .utf8)
	if let contentElement = html.css(".readings").first {
		return RawContent(content: contentElement)
	} else {
		throw ParseError.contentNotFound
	}
}

public func downloadReadings(for date: DateTuple = try! DateTuple(from: Date().components)) throws -> [StyledTextSegment] {
	let raw = try rawContent(for: date)
	let date = try raw.liturgicalDate()

	let contentElement = raw.content

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
