//
//  MainMapViewModel.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 18/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import Alamofire

protocol MainMapViewModel {
	func fetchMapResources(input: MapResourcesUseCaseInput, completionHandler: @escaping (Result<MapResource, AFError>) -> Void)
}

struct DefaultMainMapViewModel: MainMapViewModel {
	
	let mapResourcesUseCase: MapResourcesUseCase
	
	func fetchMapResources(input: MapResourcesUseCaseInput, completionHandler: @escaping (Result<MapResource, AFError>) -> Void) {
		mapResourcesUseCase.execute(
			requestValue: input,
			completionHandler: completionHandler
		)
	}
}
