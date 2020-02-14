//
//  File.swift
//  
//
//  Created by Damiaan on 14/02/2020.
//

public struct Reference {
	public let bookAbbreviation: String
	public let chapter, verse: Int
	public let subdivision: String

	public init(bookAbbreviation: String, chapter: Int, verse: Int, subdivision: String) {
		self.bookAbbreviation = bookAbbreviation
		(self.chapter, self.verse) = (chapter, verse)
		self.subdivision = subdivision
	}
}
