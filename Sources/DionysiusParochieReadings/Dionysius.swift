//
//  Calendar.swift
//  Parser
//
//  Created by Damiaan on 22/08/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Kanna
import LectionaryScraper

func dionysiusFromatter() -> DateFormatter {
	let formatter = DateFormatter()
	formatter.locale = Locale(identifier: "nl")
	formatter.dateFormat = "dd MMMM yyyy"
	return formatter
}

let formatter = dionysiusFromatter()

public let url = URL(string: "https://dionysiusparochie.nl/liturgie/lezingen/")!

public func downloadCalendar(from url: URL = url) throws -> [DateTuple:[ReadingsLocation]] {
	let html = try HTML(url: url, encoding: .utf8)

	var liturgicCalendar = [DateTuple:[ReadingsLocation]]()

	let paragraphs = html.css("body > #page #main > article.post-content > div.entry-content p")
	for paragraph in paragraphs {
		guard let dateString = paragraph
			.css("strong")
			.first?
			.normalizedText?
			.drop(while: {!CharacterSet(charactersIn: String($0)).isSubset(of: .decimalDigits)})
			.components(separatedBy: .whitespaces)
			.prefix(3)
			.joined(separator: " ")
		else { continue }
		guard let date = formatter.date(from: dateString.lowercased())?.components else { continue }
		guard let dateTuple = try? DateTuple(from: date) else {continue}

		var locations = [ReadingsLocation]()
		for cursor in paragraph.css("a[href]") {
			if let link = cursor["href"], link.contains("/lectionaria/"), let url = URL(string: link) {
				var secureURL = URLComponents(url: url, resolvingAgainstBaseURL: true)!
				secureURL.scheme = "https"
				locations.append(
					ReadingsLocation(
						title: cursor.text!,
						url: secureURL.url!
					)
				)
			}
		}
		if !locations.isEmpty {
			liturgicCalendar[dateTuple] = locations
		}
	}
	return liturgicCalendar
}

public struct RawContent {
	let content: Kanna.XMLElement

	public func psalmResponse() -> String? {
		for header in content.css("h2") {
			if header.normalizedText?.lowercased().contains("tussenzang") ?? false {
				let text = header.xpath("./following-sibling::node()//text()[contains(translate(., 'REFREIN', 'refrein'), 'refrein')][1]/following-sibling::text()").compactMap {$0.normalizedText} .joined(separator: "\n")
				return text.isEmpty ? nil : text
			}
		}
		return nil
	}

	public func verseBeforeGospel() -> (content: String?, reference: String?) {
		for header in content.css("h2") {
			if let title = header.normalizedText?.lowercased(), let range = title.range(of: "vers voor het evangelie") {
				let reference = title[range.upperBound...]
					.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union([":"]))
				var lines = [String]()
				for node in header.xpath("./following-sibling::node()") {
					if node.tagName == "h2" {break}
					lines.append(contentsOf: node.xpath("text()").compactMap { $0.normalizedText }.filter{$0 != "Alleluia."} )
				}
				return (lines.joined(separator: "\n"), reference)
			}
		}
		return (nil, nil)
	}

	public func styledText() -> [StyledTextSegment] {
		var readingsElements = [StyledTextSegment]()

		func addChilds(of element: Kanna.XMLElement) {
			let tagName = element.tagName
			if tagName == "text", let text = element.normalizedText {
				if text == "Refrein:" {
					readingsElements.append(.responseTitle)
				} else {
					readingsElements.append(.text(text))
				}
			} else if tagName == "h1", let text = element.normalizedText {
				readingsElements.append(.liturgicalDate(text))
			} else if ["h2", "strong"].contains(tagName), let text = element.normalizedText {
				let title: String
				let ref: String?
				if let tail = text.firstIndex(of: "(") {
					title = String(text.prefix(upTo: tail))
					ref = String(
						text[text.index(after: tail) ..< (text.firstIndex(of: ")") ?? text.endIndex)]
					)
				} else {
					title = text
					ref = nil
				}
				readingsElements.append(.title(title.capitalizingFirstLetter()))
				if let reference = ref {readingsElements.append(.source(reference))}
			} else {
				for child in element.xpath("child::node()") {
					addChilds(of: child)
				}
				if tagName == "p" && readingsElements.last?.isTitle == false {
					readingsElements.append(.paragraphBreak)
				} else if tagName == "br" && readingsElements.last?.isTitle == false {
					readingsElements.append(.lineBreak)
				}
			}
		}

		addChilds(of: content)

		return readingsElements
	}
}

public struct ReadingsLocation {
	public let title: String
	public let location: URL

	init(title: String, url: URL) { (self.title, location) = (title, url) }

	enum Error: Swift.Error {
		case contentNotFound
		case invalidHTML
	}

	public func download() throws -> RawContent {
		let data = try Data(contentsOf: location)
		let page: HTMLDocument
		do    { page = try HTML(html: data, encoding: .utf8)      }
		catch { page = try HTML(html: data, encoding: .isoLatin1) }
		guard let contentElement = page.css("body > #page #main > article.post-content > div.entry-content").first else {
			throw Error.contentNotFound
		}
		return RawContent(content: contentElement)
	}
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
