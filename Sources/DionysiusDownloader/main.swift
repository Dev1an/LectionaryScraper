//
//  File.swift
//  
//
//  Created by Damiaan on 15/02/2020.
//

import DionysiusParochieReadings
import Foundation

let calendar = try downloadCalendar(/* from: URL(string: "https://dionysiusparochie.nl/liturgie/lezingen/archief/")! */)

for (date, locations) in calendar {
	for location in locations {
		let fileName = "\(date.year) \(date.month.pad2) \(date.day.pad2) \(location.location.pathComponents.dropFirst().joined(separator: ":")).html"
		if let data = try? Data(contentsOf: location.location) {
			try data.write(to: URL(fileURLWithPath: "/tmp/dio/\(fileName)"))
		} else {
			print("could not open", location)
		}
	}
}
