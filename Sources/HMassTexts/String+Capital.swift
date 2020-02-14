//
//  File.swift
//  
//
//  Created by Damiaan on 14/02/2020.
//

import Foundation

extension String {
	public func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + dropFirst()
	}

	public mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
}
