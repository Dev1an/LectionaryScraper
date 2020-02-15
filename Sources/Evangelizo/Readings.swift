//
//  Readings.swift
//  Daily Gospel
//
//  Created by Damiaan Dufaux on 06/08/2018.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
import LectionaryScraper

struct EReading: Decodable {
	struct Book: Decodable {
		let fullTitle: String
	}
	
	let id: String
	let book: Book
	let type: Reading.Kind
	let text: String
	let readingCode: String
}

struct Reading {
	enum Kind: String, Decodable {
		case reading
		case gospel
		case psalm
	}
	
	typealias Verse = (reference: Reference, content: String)

	let id: String
	let book: String
	let kind: Kind
	let verses: [Verse]
	let reference: String

	static let referenceFinder = try! NSRegularExpression(
		pattern: "\\[\\[(\\w+) (\\d+),(\\d+)([a-z]*)\\]\\]",
		options: []
	)
	
	init(from reading: EReading) {
		id = reading.id
		book = reading.book.fullTitle
		kind = reading.type
		reference = reading.readingCode
		
		let referenceMatches = Reading.referenceFinder.matches(
			   in: reading.text,
			range: NSRange(0 ..< reading.text.utf16.count)
		)
		
		func getReference(from match: NSTextCheckingResult) -> Reference {
			return Reference(
				bookAbbreviation:     reading.text[match.range(at: 1)]  ,
			             chapter: Int(reading.text[match.range(at: 2)])!,
				           verse: Int(reading.text[match.range(at: 3)])!,
				     subdivision:     reading.text[match.range(at: 4)]
			)
		}
		
		var lastMatch = referenceMatches.first!
		var lastReference = getReference(from: lastMatch)
		var mutableContent = [Verse]()
		
		for match in referenceMatches.dropFirst() {
			let reference = getReference(from: match)
			let verse = reading.text[from: lastMatch.range, to: match.range]
			mutableContent.append((lastReference, verse))
			lastReference = reference
			lastMatch = match
		}
		mutableContent.append((
			lastReference,
			reading.text[NSRange(lastMatch.range.upperBound ..< reading.text.utf16.count)]
		))
		
		verses = mutableContent
	}
	
	var styledText: [StyledTextSegment] {
		var text = [StyledTextSegment]()
		text.append(.title(book) )
		text.append(.source(reference))
		for verse in verses {
			let lines = verse.content.components(separatedBy: "\n").map {$0.trimmingCharacters(in: ["\r"])}
			if let firstLine = lines.first {
				text.append(.bibleVerse(firstLine, verse.reference))
			}
			for line in lines.dropFirst() {
				switch text.last! {
					case .lineBreak: text[text.endIndex-1] = .paragraphBreak
					default: text.append(.lineBreak)
				}
				if !line.isEmpty {
					text.append(.bibleVerse(line, verse.reference))
				}
			}
		}
		switch text.last! {
			case .paragraphBreak: break
			case .lineBreak: text[text.endIndex-1] = .paragraphBreak
			default: text.append(.paragraphBreak)
		}
		return text
	}
}

extension String {
	subscript(nsRange: NSRange) -> String {
		return (self as NSString).substring(with: nsRange)
	}
	
	subscript(from start: NSRange, to end: NSRange) -> String {
		return self[NSRange(start.upperBound ..< end.lowerBound)]
	}
}
