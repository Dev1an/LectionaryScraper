//
//  Commentary.swift
//  Daily Gospel
//
//  Created by Damiaan on 13/09/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
import LectionaryScraper

struct Commentary: Decodable {
	struct Author: Decodable {
		let name: String
		let shortDescription: String?
	}
	
	let author: Author
	let description: String
	let source: String
	let title: String
	
	var styledText: [StyledTextSegment] {
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
