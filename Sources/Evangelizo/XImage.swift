//
//  XImage.swift
//  Daily Gospel
//
//  Created by Damiaan on 14/09/18.
//  Copyright © 2018 Devian. All rights reserved.
//

#if os(iOS) || os(watchOS)
import UIKit
public typealias XImage = UIImage
#elseif os(macOS)
import AppKit
public typealias XImage = NSImage
#endif
