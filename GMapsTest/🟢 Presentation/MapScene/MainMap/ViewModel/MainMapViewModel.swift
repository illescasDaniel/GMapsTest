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
	func mapResourceAttributedString(
			marker: MapResourceMarker,
			mapResource: MapResource.Element
	) -> (addedAttributes: Int, string: NSAttributedString)
}

struct DefaultMainMapViewModel: MainMapViewModel {
	
	let mapResourcesUseCase: MapResourcesUseCase
	
	func fetchMapResources(input: MapResourcesUseCaseInput, completionHandler: @escaping (Result<MapResource, AFError>) -> Void) {
		mapResourcesUseCase.execute(
			requestValue: input,
			completionHandler: completionHandler
		)
	}

	func mapResourceAttributedString(
			marker: MapResourceMarker,
			mapResource: MapResource.Element
	) -> (addedAttributes: Int, string: NSAttributedString) {

		var addedAttributes = 0
		let detailAttributedString = NSMutableAttributedString()

		typealias l10n = L10n.MainMapView.ResourceAttributes

		if let resourceType = mapResource.resourceType, !resourceType.isEmpty {
			detailAttributedString.append(bold("\(l10n.type): "))
			detailAttributedString.append(normal(resourceType+"\n"))
			addedAttributes += 1
		}
		if let model = mapResource.model, !model.isEmpty {
			detailAttributedString.append(bold("\(l10n.model): "))
			detailAttributedString.append(normal(model+"\n"))
			addedAttributes += 1
		}
		if let licencePlate = mapResource.licencePlate, !licencePlate.isEmpty {
			detailAttributedString.append(bold("\(l10n.licensePlate): "))
			detailAttributedString.append(normal(licencePlate+"\n"))
			addedAttributes += 1
		}
		if let engineType = mapResource.engineType, !engineType.isEmpty {
			detailAttributedString.append(bold("\(l10n.engineType): "))
			detailAttributedString.append(normal(engineType+"\n"))
			addedAttributes += 1
		}
		if let seats = mapResource.seats {
			detailAttributedString.append(bold("\(l10n.seats): "))
			detailAttributedString.append(normal(String(seats)+"\n"))
			addedAttributes += 1
		}

		if let station = mapResource.station {
			detailAttributedString.append(bold("\(l10n.station): "))
			detailAttributedString.append(normal((station ? "Yes" : "No") + "\n"))
			addedAttributes += 1
		}
		if let availableResources = mapResource.availableResources {
			detailAttributedString.append(bold("\(l10n.availableResources): "))
			detailAttributedString.append(normal(String(availableResources)+"\n"))
			addedAttributes += 1
		}
		if let spacesAvailable = mapResource.spacesAvailable {
			detailAttributedString.append(bold("\(l10n.spacesAvailable): "))
			detailAttributedString.append(normal(String(spacesAvailable)+"\n"))
			addedAttributes += 1
		}

		if let bikesAvailable = mapResource.bikesAvailable {
			detailAttributedString.append(bold("\(l10n.bikesAvailable): "))
			detailAttributedString.append(normal(String(bikesAvailable)+"\n"))
			addedAttributes += 1
		}

		if let allowDropOff = mapResource.allowDropOff {
			detailAttributedString.append(bold("\(l10n.allowDropOff): "))
			detailAttributedString.append(normal((allowDropOff ? "Yes" : "No") + "\n"))
			addedAttributes += 1
		}

		if let pricePerMinuteParking = mapResource.pricePerMinuteParking {
			detailAttributedString.append(bold("\(l10n.pricePerMinuteParking): "))
			detailAttributedString.append(normal(String(pricePerMinuteParking) + "\n"))
			addedAttributes += 1
		}
		if let pricePerMinuteDriving = mapResource.pricePerMinuteDriving {
			detailAttributedString.append(bold("\(l10n.pricePerMinuteDriving): "))
			detailAttributedString.append(normal(String(pricePerMinuteDriving) + "\n"))
			addedAttributes += 1
		}

		if let helmets = mapResource.helmets {
			detailAttributedString.append(bold("\(l10n.helmets): "))
			detailAttributedString.append(normal(String(helmets)+"\n"))
			addedAttributes += 1
		}

		return (addedAttributes, detailAttributedString)
	}

	private func bold(_ string: String) -> NSAttributedString {
		return NSAttributedString(
				string: string,
				attributes: [
					.font: UIFont.preferredFont(forTextStyle: .headline)
				]
		)
	}

	private func normal(_ string: String) -> NSAttributedString {
		return NSAttributedString(
				string: string,
				attributes: [
					.font: UIFont.preferredFont(forTextStyle: .body)
				]
		)
	}
}
