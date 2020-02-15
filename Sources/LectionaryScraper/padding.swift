//
//  padding.swift
//  Daily Gospel
//
//  Created by Damiaan on 28/01/18.
//  Copyright © 2018 Devian. All rights reserved.
//

import Foundation

extension BinaryInteger {
	public var pad2: String {
		return String(format: "%02d", self as! CVarArg)
	}
}
