//
//  ViewController.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps

class MainMapViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var mapView: GMSMapView!
	@IBOutlet weak var currentPlaceLabel: UILabel!
	@IBOutlet weak var currentLocationLabel: UILabel!
	
	// MARK: Properties
	
	private let viewModel: MainMapViewModel = MapSceneDependencies.makeMainMapViewModel()
	
	private lazy var locationManager = CLLocationManager()
	private var markers: [GMSMarker] = []
	private var lastKnownCoordinate: LocationCoordinate?
	private var lastKnownVisibleRegionCorners: (nearLeft: LocationCoordinate, farRight: LocationCoordinate)?
	
	private var observers: [NSKeyValueObservation] = []

	// If `companyZoneID` was a discrete value, I could easily map all possible values to different colors
	// but I don't know all the possible values of it
	private let markerColors: [UIColor] = [
		.red, .green, .blue, .yellow, .brown, .cyan
	]
	private lazy var currentMarkerColorIterator = markerColors.makeIterator()
	private var colorGivenACompanyZoneId: [Int: UIColor] = [:]
	
	// MARK: Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupGoogleMaps()
		setupLocationManager()
	}
	
	deinit {
		observers.forEach {
			$0.invalidate()
		}
		observers.removeAll()
	}
	
	private func setupView() {
		
		setupGoogleMapsView()
		
		self.currentPlaceLabel.numberOfLines = 0
		self.currentPlaceLabel.textAlignment = .center
		self.currentPlaceLabel.text = ""
		
		self.currentLocationLabel.numberOfLines = 0
		self.currentLocationLabel.text = ""
	}
	
	private func setupGoogleMapsView() {
		// todo: put this elsewhere
		let lisboa = LocationCoordinate(latitude: 38.711046, longitude: -9.160096)
		
		let camera = GMSCameraPosition.camera(withLatitude: lisboa.latitude, longitude: lisboa.longitude, zoom: 13)
		mapView.camera = camera
		mapView.delegate = self
	}
	
	private func setupGoogleMaps() {
		
		mapView.isMyLocationEnabled = true
		mapView.settings.myLocationButton = true
		mapView.settings.compassButton = true
		
		observers.append(self.mapView.observe(\.camera, options: [.initial, .new]) { (mapView, change) in
			guard change.oldValue /* initial */ ?? change.newValue != nil else { return }
			
			let visibleRegion = self.mapView.projection.visibleRegion()
			let visibleRegionCorners = (visibleRegion.nearLeft, visibleRegion.farRight)
			if self.lastKnownVisibleRegionCorners == nil || self.lastKnownVisibleRegionCorners! != visibleRegionCorners {
				self.lastKnownVisibleRegionCorners = visibleRegionCorners
				self.loadMarkers(visibleRegionCorners: visibleRegionCorners)
			}
		})
	}
	
	private func setupLocationManager() {
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.distanceFilter = 10
		locationManager.startUpdatingLocation()
		locationManager.delegate = self
	}
	
	//
	
	// todo: filter?? make clusters?

	// load markers as the map viewport changes
	private func loadMarkers(visibleRegionCorners: (nearLeft: LocationCoordinate, farRight: LocationCoordinate)) {

		var newMarkers: [GMSMarker] = []
		
		self.viewModel.fetchMapResources(
			input: .init(mapFrame: MapFrame(
				lowerLeft: visibleRegionCorners.nearLeft,
				upperRight: visibleRegionCorners.farRight
			)),
			completionHandler: {
				
				guard let mapResources = (try? $0.get())?.mapResource else { return }
				
				// todo: what's the difference between the service response parameters:
				// "x","y" vs "lon","lat" parameters

				// todo: just testing some resources!!, if I choose to display ALL of them it lags, because they are
				// a lot, I'll need to use markers clustering !
				let first10MapResources = mapResources.count > 10 ? Array(mapResources[0..<10]) : mapResources
				let last10MapResources = mapResources.count > 10 ? Array(mapResources[(mapResources.count-10)...]) : mapResources
				let someMapResources = first10MapResources + last10MapResources
				
				DispatchQueue.concurrentPerform(iterations: someMapResources.count) { (index) in
					DispatchQueue.main.async {
						let mapResource = someMapResources[index]
						let position = CLLocationCoordinate2D(latitude: mapResource.y, longitude: mapResource.x)
						guard !self.markers.contains(where: { $0.position == position}) else { return }
						let marker = MapResourceMarker()
						marker.position = CLLocationCoordinate2D(latitude: mapResource.y, longitude: mapResource.x)
						self.setupMarkerInfo(marker: marker, mapResource: mapResource)
						newMarkers.append(marker)
					}
				}

				DispatchQueue.main.async {
					for (i, marker) in newMarkers.enumerated() {
						DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20 * i)) {
							marker.map = self.mapView
						}
					}
					self.markers += newMarkers
				}
			}
		)
	}
	
	private func setupMarkerInfo(marker: MapResourceMarker, mapResource: MapResource.Element) {
		marker.title = mapResource.name
		marker.mapResource = mapResource
		if let color = colorGivenACompanyZoneId[mapResource.companyZoneID] {
			marker.icon = GMSMarker.markerImage(with: color)
		} else {
			var color = currentMarkerColorIterator.next()
			if color == nil {
				currentMarkerColorIterator = markerColors.makeIterator()
				color = currentMarkerColorIterator.next()
			}
			guard let aColor = color else { return }
			colorGivenACompanyZoneId[mapResource.companyZoneID] = aColor
			marker.icon = GMSMarker.markerImage(with: aColor)
		}
	}
}

extension MainMapViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		let lastCoordinate = manager.location?.coordinate
		
		guard lastKnownCoordinate != lastCoordinate else {
			return
		}
		lastKnownCoordinate = lastCoordinate
		
		guard let currentCoordinate = lastKnownCoordinate else { return }
		
		updateCurrentPlaceLabel(currentCoordinate: currentCoordinate)
		updateCurrentLocationLabel(currentCoordinate: currentCoordinate)
		
		// follows last user location
		
		//guard let lastLocation = locations.last else { return }
		//		let camera = GMSCameraPosition.camera(
		//			withLatitude: lastLocation.coordinate.latitude,
		//			longitude: lastLocation.coordinate.longitude,
		//			zoom: mapView.camera.zoom
		//		)
		//		mapView.camera = camera
	}
	
	private func updateCurrentPlaceLabel(currentCoordinate: LocationCoordinate) {
		GMSGeocoder().reverseGeocodeCoordinate(currentCoordinate) { (response, error) in
			if let error = error {
				log.error(error)
				return
			}
			guard let response = response else {
				log.info("null geocode response")
				return
			}
			
			guard let firstResult = response.firstResult() else {
				return
			}
			
			let attributedString = NSMutableAttributedString()
			attributedString.append(NSAttributedString(string: "Place: ", attributes: [
				.font: UIFont.boldSystemFont(ofSize: 16)
			]))
			attributedString.append(NSAttributedString(string: "\(firstResult.country ?? "?") - \(firstResult.administrativeArea ?? "")", attributes: [
				.font: UIFont.systemFont(ofSize: 15)
			]))
			attributedString.append(NSAttributedString(string: "\nCity: ", attributes: [
				.font: UIFont.boldSystemFont(ofSize: 16)
			]))
			attributedString.append(NSAttributedString(string: "\(firstResult.locality ?? "?")", attributes: [
				.font: UIFont.systemFont(ofSize: 15)
			]))
			attributedString.append(NSAttributedString(string: "\nAddress: ", attributes: [
				.font: UIFont.boldSystemFont(ofSize: 16)
			]))
			attributedString.append(NSAttributedString(string: "\(firstResult.lines?.first ?? "?")", attributes: [
				.font: UIFont.systemFont(ofSize: 14)
			]))
			self.currentPlaceLabel.attributedText = attributedString
			print()
		}
	}
	
	private func updateCurrentLocationLabel(currentCoordinate: LocationCoordinate) {
		
		let attributedString = NSMutableAttributedString()
		attributedString.append(NSAttributedString(string: "Latitude: ", attributes: [
			.font: UIFont.boldSystemFont(ofSize: 16)
		]))
		attributedString.append(NSAttributedString(string: "\(currentCoordinate.latitude)º", attributes: [
			.font: UIFont.systemFont(ofSize: 15)
		]))
		attributedString.append(NSAttributedString(string: "\nLongitude: ", attributes: [
			.font: UIFont.boldSystemFont(ofSize: 16)
		]))
		attributedString.append(NSAttributedString(string: "\(currentCoordinate.longitude)º", attributes: [
			.font: UIFont.systemFont(ofSize: 15)
		]))
		
		self.currentLocationLabel.attributedText = attributedString
	}
}

extension MainMapViewController: GMSMapViewDelegate {

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

	func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
		guard let marker = marker as? MapResourceMarker, let mapResource = marker.mapResource else { return nil }

		var things = 0
		let detailAttributedString = NSMutableAttributedString()

		if let resourceType = mapResource.resourceType, !resourceType.isEmpty {
			detailAttributedString.append(bold("Type: "))
			detailAttributedString.append(normal(resourceType+"\n"))
			things += 1
		}
		if let model = mapResource.model, !model.isEmpty {
			detailAttributedString.append(bold("Model: "))
			detailAttributedString.append(normal(model+"\n"))
			things += 1
		}
		if let licencePlate = mapResource.licencePlate, !licencePlate.isEmpty {
			detailAttributedString.append(bold("License plate: "))
			detailAttributedString.append(normal(licencePlate+"\n"))
			things += 1
		}
		if let engineType = mapResource.engineType, !engineType.isEmpty {
			detailAttributedString.append(bold("Engine type: "))
			detailAttributedString.append(normal(engineType+"\n"))
			things += 1
		}
		if let seats = mapResource.seats {
			detailAttributedString.append(bold("Seats: "))
			detailAttributedString.append(normal(String(seats)+"\n"))
			things += 1
		}

		if let station = mapResource.station {
			detailAttributedString.append(bold("Station: "))
			detailAttributedString.append(normal((station ? "Yes" : "No") + "\n"))
			things += 1
		}
		if let availableResources = mapResource.availableResources {
			detailAttributedString.append(bold("Available resources: "))
			detailAttributedString.append(normal(String(availableResources)+"\n"))
			things += 1
		}
		if let spacesAvailable = mapResource.spacesAvailable {
			detailAttributedString.append(bold("Spaces available: "))
			detailAttributedString.append(normal(String(spacesAvailable)+"\n"))
			things += 1
		}

		if let bikesAvailable = mapResource.bikesAvailable {
			detailAttributedString.append(bold("Bikes available: "))
			detailAttributedString.append(normal(String(bikesAvailable)+"\n"))
			things += 1
		}

		if let allowDropOff = mapResource.allowDropOff {
			detailAttributedString.append(bold("Allow drop off: "))
			detailAttributedString.append(normal((allowDropOff ? "Yes" : "No") + "\n"))
			things += 1
		}

		if let pricePerMinuteParking = mapResource.pricePerMinuteParking {
			detailAttributedString.append(bold("PPM Parking: "))
			detailAttributedString.append(normal(String(pricePerMinuteParking) + "\n"))
			things += 1
		}
		if let pricePerMinuteDriving = mapResource.pricePerMinuteParking {
			detailAttributedString.append(bold("PPM Driving: "))
			detailAttributedString.append(normal(String(pricePerMinuteDriving) + "\n"))
			things += 1
		}

		if let helmets = mapResource.helmets {
			detailAttributedString.append(bold("Helmets: "))
			detailAttributedString.append(normal(String(helmets)+"\n"))
			things += 1
		}

		let width = self.view.frame.size.width
		let customMarkerDetailView = MarkerDetailView.create(
			withBounds: CGRect(x: 0, y: 0, width: width > 450 ? 350 : width * 0.75, height: things < 2 ? 80 : 240),
			title: marker.title ?? "?",
			body: detailAttributedString
		)
		if things == 0 {
			customMarkerDetailView?.bodyLabel.isHidden = true
		} else {
			customMarkerDetailView?.bodyLabel.isHidden = false
		}
		return customMarkerDetailView
	}
}
