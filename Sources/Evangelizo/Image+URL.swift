//
//  UIImage+URL.swift
//  Daily Gospel
//
//  Created by Damiaan on 23/10/17.
//  Copyright © 2017 Devian. All rights reserved.
//

#if os(iOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension XImage {
	convenience init?(from url: URL?) {
		if let url = url, let data = try? Data(contentsOf: url) {
			self.init(data: data)
		} else {
			return nil
		}
	}
}
