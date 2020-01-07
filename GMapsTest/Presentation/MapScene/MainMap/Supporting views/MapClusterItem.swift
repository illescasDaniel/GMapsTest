//
// Created by Daniel Illescas Romero on 20/12/2019.
// Copyright (c) 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class MapClusterItem: NSObject, GMUClusterItem {

	var position: CLLocationCoordinate2D
	var name: String
	var mapResource: MapResource.Element?

	init(position: CLLocationCoordinate2D, name: String) {
		self.position = position
		self.name = name
	}
}
