//
// Created by Daniel Illescas Romero on 20/12/2019.
// Copyright (c) 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

class MapClusterRenderer: GMUDefaultClusterRenderer {
	override func shouldRender(as cluster: GMUCluster?, atZoom zoom: Float) -> Bool {
		return zoom < 16
	}
}
