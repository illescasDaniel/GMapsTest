//
//  MapResources.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import Alamofire

protocol MapResourcesRepository {
	func resources(mapFrame: MapFrame, completionHandler: @escaping (Result<MapResource, AFError>) -> Void)
}
