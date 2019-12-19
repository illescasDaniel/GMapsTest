//
//  MapResource+Decodable.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

extension MapResource: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.mapResource = try container.decode([MapResource.Element].self)
	}
}
extension MapResource.Element: Decodable {
	
	private enum CodingKeys: String, CodingKey {
		case id
		case name
		case x, y
		case companyZoneID = "companyZoneId"
		case longitude = "lon", latitude = "lat"
		case licencePlate, range, batteryLevel, seats, model
		case resourceImageID = "resourceImageId"
		case pricePerMinuteParking, pricePerMinuteDriving, realTimeData, engineType, resourceType, helmets, station, availableResources, spacesAvailable, allowDropoff, bikesAvailable
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		func decode<T: Decodable>(forKey key: Self.CodingKeys) throws -> T {
			return try container.decode(T.self, forKey: key)
		}
		func decodeIfPresent<T: Decodable>(forKey key: Self.CodingKeys) throws -> T? {
			return try container.decodeIfPresent(T.self, forKey: key)
		}
		
		self.id = try decode(forKey: .id)
		self.name = try decode(forKey: .name)
		
		self.x = try decode(forKey: .x)
		self.y = try decode(forKey: .y)
		
		if let latitude: Double = try decodeIfPresent(forKey: .latitude),
			let longitude: Double = try decodeIfPresent(forKey: .longitude) {
			
			self.mapCoordinate = .init(latitude: latitude, longitude: longitude)
		} else {
			self.mapCoordinate = nil
		}
		
		self.companyZoneID = try decode(forKey:  .companyZoneID)
		self.licencePlate = try decodeIfPresent(forKey: .licencePlate)
		self.range = try decodeIfPresent(forKey: .range)
		self.betteryLevel = try decodeIfPresent(forKey: .batteryLevel)
		self.seats = try decodeIfPresent(forKey: .seats)
		self.model = try decodeIfPresent(forKey: .model)
		self.resourceImageID = try decodeIfPresent(forKey: .resourceImageID)
		self.pricePerMinuteParking = try decodeIfPresent(forKey: .pricePerMinuteParking)
		self.pricePerMinuteDriving = try decodeIfPresent(forKey: .pricePerMinuteDriving)
		
		self.realTimeData = try decodeIfPresent(forKey: .realTimeData)
		self.engineType = try decodeIfPresent(forKey: .engineType)
		self.resourceType = try decodeIfPresent(forKey: .resourceType)
		
		self.helmets = try decodeIfPresent(forKey: .helmets)
		self.station = try decodeIfPresent(forKey: .station)
		self.availableResources = try decodeIfPresent(forKey: .availableResources)
		self.spacesAvailable = try decodeIfPresent(forKey: .spacesAvailable)
		self.bikesAvailable = try decodeIfPresent(forKey: .bikesAvailable)
		self.allowDropoff = try decodeIfPresent(forKey: .allowDropoff)
	}
}

