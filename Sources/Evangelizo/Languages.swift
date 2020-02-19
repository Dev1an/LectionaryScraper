//
//  Languages.swift
//  
//
//  Created by Damiaan on 19/02/2020.
//

import Foundation

public enum LanguageTag: String {
	case german = "DE"
	case greek = "GR"
	case english = "AM"
	case dutch = "NL"
	case spanish = "SP"
	case french = "FR"
	case polish = "PL"
	case chinese = "CN"
	case arabic = "AR"
	case italian = "IT"
	case irish = "GA"
	case armenian = "ARM"
	case korean = "KR"
	case malagasy = "MG"
	case portugese = "PT"
	case russian = "RU"
	case turkish = "TR"
}

public let languageTags: [String: LanguageTag] = [
	"de": .german,
	"el": .greek,
	"en": .english,
	"nl": .dutch,
	"es": .spanish,
	"fr": .french,
	"pl": .polish,
	"zh": .chinese,
	"ar": .arabic,
	"it": .italian,
	"ga": .irish,
	"hy": .armenian,
	"ko": .korean,
	"mg": .malagasy,
	"pt": .portugese,
	"ru": .russian,
	"tr": .turkish
]

let defaultLanguageTag = LanguageTag.english

public func currentLanguageTag() -> LanguageTag {
	let preferredLanguage = Locale.preferredLanguages.compactMap{Locale(identifier: $0).languageCode}.first{ languageTags.keys.contains($0) }
	if let code = preferredLanguage {
		return languageTags[code] ?? defaultLanguageTag
	} else {
		return defaultLanguageTag
	}
}
