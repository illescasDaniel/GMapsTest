//
//  DefaultMapResourcesRepository.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import Alamofire

struct DefaultMapResourcesRepository: MapResourcesRepository {
	func resources(mapFrame: MapFrame, completionHandler: @escaping (Result<MapResource, AFError>) -> Void) {
		AF.networkRequestWithJSONResponse(
			builder: MapResourceEndpoint(mapFrame: mapFrame),
			completionHandler: completionHandler
		)
	}
}
