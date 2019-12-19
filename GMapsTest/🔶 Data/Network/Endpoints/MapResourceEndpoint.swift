//
//  MapResourceNetworkRequestBuilder.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import Alamofire

struct MapResourceEndpoint {
	
	let mapFrame: MapFrame
	
	private enum CodingKeys: String {
		case lowerLeftLatitudeLongitude = "lowerLeftLatLon"
		case upperRightLatitudeLongitude = "upperRightLatLon"
	}
}
extension MapResourceEndpoint: NetworkRequestBuilder {
	
	var baseURL: String { "https://apidev.meep.me" }
	
	var path: String {
		"/tripplan/api/v1/routers/lisboa/resources"
	}
	
	var httpMethod: HTTPMethod { .get }
	
	var queryItems: [URLQueryItem]? {[
		.init(
			name: CodingKeys.lowerLeftLatitudeLongitude.rawValue,
			value: "\(mapFrame.lowerLeft.latitude),\(mapFrame.lowerLeft.longitude)"
		),
		.init(
			name: CodingKeys.upperRightLatitudeLongitude.rawValue,
			value: "\(mapFrame.upperRight.latitude),\(mapFrame.upperRight.longitude)"
		)
	]}
}
