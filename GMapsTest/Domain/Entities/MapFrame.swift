//
//  MapFrame.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import struct CoreLocation.CLLocationCoordinate2D

typealias LocationCoordinate = CLLocationCoordinate2D

extension LocationCoordinate: Equatable {
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
	}
}

struct MapFrame {
	let lowerLeft: LocationCoordinate
	let upperRight: LocationCoordinate
}
