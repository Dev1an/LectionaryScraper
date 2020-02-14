//
//  TextStyles.swift
//  Daily Gospel
//
//  Created by Damiaan on 13/09/18.
//  Copyright © 2018 Devian. All rights reserved.
//

public enum StyledTextSegment {
	case title(String)
	case liturgicalDate(String)
	case text(String)
	case bibleVerse(String, Reference)
	case source(String)
	case responseTitle
	case paragraphBreak
	case lineBreak
	
	public var isTitle: Bool {
		if case .title(_) = self {
			return true
		} else {
			return false
		}
	}
	
	public var isBibleVerse: Bool {
		if case .bibleVerse(_, _) = self {
			return true
		} else {
			return false
		}
	}
}
