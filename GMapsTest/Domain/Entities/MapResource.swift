//
//  MapResource.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct MapResource {
	let mapResource: [Element]
}

extension MapResource {
	
	struct Element {
		
		let id: String
		let name: String
		
		let x, y: Double // what's the difference between mapCoordinate??
		let mapCoordinate: LocationCoordinate?
		
		let companyZoneID: Int // zone ID
		
		let resourceType: String? // ResourceType?
		let resourceImageID: String?
		let licencePlate: String?
		let engineType: String?
		let seats: Int?
		let model: String?
		let realTimeData: Bool?
		let range, betteryLevel: Int?
		let pricePerMinuteParking, pricePerMinuteDriving: Int?
		let helmets: Int?
		
		let station: Bool?
		let availableResources, spacesAvailable: Int?
		let bikesAvailable: Int?
		let allowDropoff: Bool?
	}

	/*enum ResourceType: String {
		case car = "CAR"
		case electricCar = "ELECTRIC_CAR"
		case moped = "MOPED"
	}*/
}
