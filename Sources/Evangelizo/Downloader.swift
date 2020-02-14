//
//  Evangelizo.swift
//  Daily Gospel
//
//  Created by Damiaan on 23/10/17.
//  Copyright © 2017 Devian. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import os
import HMassTexts

let dutchLanguageTag = "NL"
let englishLanguageTag = "AM"

public let languageTags = [
	"de": "DE",
	"el": "GR",
	"en": englishLanguageTag,
	"es": "SP",
	"fr": "FR",
	"nl": dutchLanguageTag,
	"pl": "PL",
	"zh": "CN",
	"ar": "AR",
]

public let evangelizoSourceMentioning = "The above content is downloaded from evangelizo.org"

public struct DayContainer: Decodable {
	public struct Entry: Decodable {
		let saints: [Saint]
		let readings: [EReading]
		let date: String
		let liturgicTitle: String
		let commentary: Commentary?
		
		public var readingsWithCommentary: [StyledTextSegment] {
			var text = [StyledTextSegment.liturgicalDate(liturgicTitle)]
			text.append(contentsOf: readings.flatMap { Reading(from: $0).styledText })
			if let commentary = commentary {
				text.append(contentsOf: commentary.styledText)
				text.append(.paragraphBreak)
			}
			text.append(.source(evangelizoSourceMentioning))
			return text
		}
	}
	let data: Entry
}

enum EvangelizoError: Error {
	case unableToConstructURL(String)
	case unableToLoadInfo
	case unableToDownloadRemoteData
}

let jsonDecoder = JSONDecoder()

let defaultLanguageTag = englishLanguageTag
public func currentLanguageTag() -> String {
	let preferredLanguage = Locale.preferredLanguages.compactMap{Locale(identifier: $0).languageCode}.first{ languageTags.keys.contains($0) }
	if let code = preferredLanguage {
		return languageTags[code] ?? defaultLanguageTag
	} else {
		return defaultLanguageTag
	}
}

public enum DownloadPriority: Float {
	case normal = 0.6
	case preFetch = 0.5
	case background = 0
}

let baseURL = "https://publication.evangelizo.ws"
public func downloadLiturgicalInfo(of date: DateTuple = try! DateTuple(from: Date().components), session: URLSession, priority: DownloadPriority, language: String = currentLanguageTag(), completionHandler: @escaping (Result<DayContainer.Entry, Error>) -> Void) {
	do {
		let location = "\(baseURL)/\(language)/days/\(date.year)-\(date.month.pad2)-\(date.day.pad2)"
		guard let url = URL(string: location) else {
			throw EvangelizoError.unableToConstructURL(location)
		}
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("DailyGospel iOS app by github.com/Dev1an", forHTTPHeaderField: "User-Agent")
		request.cachePolicy = .returnCacheDataElseLoad
		let task = session.dataTask(with: request) { (data, response, error) in
			do {
				if let data = data {
					jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
					let json = try jsonDecoder.decode(DayContainer.self, from: data)
					completionHandler(.success(json.data))
				} else if let error = error {
					completionHandler(.failure(error))
				} else {
					completionHandler(.failure(EvangelizoError.unableToDownloadRemoteData))
				}
			} catch {
				completionHandler(.failure(error))
			}
		}
		task.priority = priority.rawValue
		print("downloading", priority)
		task.resume()
	} catch {
		completionHandler(.failure(error))
	}
}
