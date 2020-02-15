//
//  Commentary.swift
//  Daily Gospel
//
//  Created by Damiaan on 13/09/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
import LectionaryScraper

public struct Commentary: Decodable {
	public struct Author: Decodable {
		public let name: String
		public let shortDescription: String?
	}
	
	public let author: Author
	public let description: String
	public let source: String
	public let title: String
	
	public var styledText: [StyledTextSegment] {
		var text = [StyledTextSegment]()
		// Title
		text.append(.title(title))

		// Author - description
		// Source
		text.append(.source(author.name))
		if let authorDescrition = author.shortDescription {
			text.append(.source(" - " + authorDescrition))
		}
		text.append(.lineBreak)
		text.append(.source(source))
		text.append(.paragraphBreak)

		// Commentary
		text.append(.text(description))
		return text
	}
}
