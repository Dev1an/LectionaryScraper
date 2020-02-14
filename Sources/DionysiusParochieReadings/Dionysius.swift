//
//  Calendar.swift
//  Parser
//
//  Created by Damiaan on 22/08/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
import Kanna
import HMassTexts

func dionysiusFromatter() -> DateFormatter {
	let formatter = DateFormatter()
	formatter.locale = Locale(identifier: "nl")
	formatter.dateFormat = "dd MMMM yyyy"
	return formatter
}

let formatter = dionysiusFromatter()

let url = URL(string: "https://dionysiusparochie.nl/liturgie/lezingen/")!

public func downloadCalendar() throws -> [DateTuple:[ReadingsLocation]] {
	let html = try HTML(url: url, encoding: .utf8)

	var liturgicCalendar = [DateTuple:[ReadingsLocation]]()

	let paragraphs = html.css("body > #page #main > article.post-content > div.entry-content p")
	for paragraph in paragraphs {
		guard let dateString = paragraph
			.css("strong")
			.first?
			.normalizedText?
			.drop(while: {!CharacterSet(charactersIn: String($0)).isSubset(of: .decimalDigits)})
			.prefix(while: {$0 != ":"})
		else { continue }
		guard let date = formatter.date(from: dateString.lowercased())?.components else { continue }
		guard let dateTuple = try? DateTuple(from: date) else {continue}

		var locations = [ReadingsLocation]()
		for cursor in paragraph.xpath("./a[@href][1] | ./a[@href][1]/following-sibling::*") {
			if cursor.tagName == "a" {
				if let link = cursor["href"], let url = URL(string: link) {
					var secureURL = URLComponents(url: url, resolvingAgainstBaseURL: true)!
					secureURL.scheme = "https"
					locations.append(
						ReadingsLocation(
							title: cursor.text!,
							url: secureURL.url!
						)
					)
				}
			} else if cursor.tagName == "br" {
				break
			}
		}
		if !locations.isEmpty {
			liturgicCalendar[dateTuple] = locations
		}
	}
	return liturgicCalendar
}

public struct ReadingsLocation {
	public let title: String
	public let location: URL

	init(title: String, url: URL) { (self.title, location) = (title, url) }

	enum Error: Swift.Error {
		case contentNotFound
		case invalidHTML
	}

	public func download() throws -> [StyledTextSegment] {
		let data = try Data(contentsOf: location)
		let page: HTMLDocument
		do    { page = try HTML(html: data, encoding: .utf8)      }
		catch { page = try HTML(html: data, encoding: .isoLatin1) }
		guard let contentElement = page.css("body > #page #main > article.post-content > div.entry-content").first else {
			throw Error.contentNotFound
		}

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
				let tail = text.firstIndex(of: "(") ?? text.endIndex
				readingsElements.append(.title(String(text.prefix(upTo: tail)).capitalizingFirstLetter()))
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

		addChilds(of: contentElement)

		return readingsElements
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
