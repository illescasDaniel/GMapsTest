//
//  MapSceneDependencies.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 18/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct MapSceneDependencies {
	
	static func makeMapResourcesRepository() -> MapResourcesRepository {
		DefaultMapResourcesRepository()
	}
	
	static func makeMapResourcesUseCase() -> MapResourcesUseCase {
		DefaultMapResourcesUseCase(mapResourcesRepository: makeMapResourcesRepository())
	}
	
	static func makeMainMapViewModel() -> MainMapViewModel {
		DefaultMainMapViewModel(mapResourcesUseCase: makeMapResourcesUseCase())
	}
}
