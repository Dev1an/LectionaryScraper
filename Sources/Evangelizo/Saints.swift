//
//  Saints.swift
//  Daily Gospel
//
//  Created by Damiaan on 22/08/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation
import Kanna
#if os(watchOS)
import WatchKit
#endif

struct Saint: Decodable, Equatable {
	let id: String
	let name: String
	
	let imageLinks: ImageLinks?

	let biography: String?
	let shortDescription: String?
	
	mutating func formattedBioraphy() throws -> NSMutableAttributedString {
		let html = try HTML(html: biography!, encoding: .utf8)
		if let firstParagraph = html.css("p").first {
			firstParagraph.parent?.removeChild(firstParagraph)
		}
		return try NSMutableAttributedString(
			data: html.toHTML!.data(using: .utf8)!,
			options: [
				.documentType : NSAttributedString.DocumentType.html,
				.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		)
	}
	
	struct ImageLinks: Decodable {
		let face: URL?
		let large: URL?
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case imageLinks
		case biography = "bio"
		case shortDescription
	}
	
	public static func == (lhs: Saint, rhs: Saint) -> Bool {
		return lhs.id == rhs.id
	}
}
