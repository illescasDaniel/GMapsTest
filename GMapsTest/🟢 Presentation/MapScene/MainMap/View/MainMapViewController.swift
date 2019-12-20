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
	private var clusterItems: [MapClusterItem] = []
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

	private lazy var clusterManager: GMUClusterManager = {
		let iconGenerator = GMUDefaultClusterIconGenerator()
		let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
		let renderer = MapClusterRenderer(
			mapView: mapView,
			clusterIconGenerator: iconGenerator
		)
		renderer.delegate = self
		return GMUClusterManager(
			map: mapView,
			algorithm: algorithm,
			renderer: renderer
		)
	}()

	// lisboa
	let initialCoordinates = LocationCoordinate(latitude: 38.711046, longitude: -9.160096)
	
	// MARK: Life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupGoogleMaps()
		setupLocationManager()

		loadMarkersForVisibleRegion()
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
		let camera = GMSCameraPosition.camera(
			withLatitude: initialCoordinates.latitude,
			longitude: initialCoordinates.longitude,
			zoom: 13
		)
		mapView.camera = camera
		mapView.delegate = self
	}
	
	private func setupGoogleMaps() {
		
		mapView.isMyLocationEnabled = true
		mapView.settings.myLocationButton = true
		mapView.settings.compassButton = true

		clusterManager.setDelegate(self, mapDelegate: self)
	}
	
	private func setupLocationManager() {
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.distanceFilter = 10
		locationManager.startUpdatingLocation()
		locationManager.delegate = self
	}
	
	//

	// load markers as the map viewport changes
	private func loadMarkers(visibleRegionCorners: (nearLeft: LocationCoordinate, farRight: LocationCoordinate)) {

		self.viewModel.fetchMapResources(
			input: .init(mapFrame: MapFrame(
				lowerLeft: visibleRegionCorners.nearLeft,
				upperRight: visibleRegionCorners.farRight
			)),
			completionHandler: {

				guard let mapResources = (try? $0.get())?.mapResource else { return }

				DispatchQueue.main.async {
					for mapResource in mapResources {
						let position = LocationCoordinate(latitude: mapResource.y, longitude: mapResource.x)

						if !self.clusterItems.contains(where: { $0.position == position}) {
							let item = MapClusterItem(position: position, name: mapResource.name)
							item.mapResource = mapResource
							self.clusterItems.append(item)
							self.clusterManager.add(item)
						}
					}
					self.clusterManager.cluster()
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

	func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
		// checking this flag avoids markers reload (network call) when tapping on one to see its detail
		if gesture {
			loadMarkersForVisibleRegion()
		}
	}

	private func loadMarkersForVisibleRegion() {
		let visibleRegion = self.mapView.projection.visibleRegion()
		let visibleRegionCorners = (visibleRegion.nearLeft, visibleRegion.farRight)
		if self.lastKnownVisibleRegionCorners == nil || self.lastKnownVisibleRegionCorners! != visibleRegionCorners {
			self.lastKnownVisibleRegionCorners = visibleRegionCorners
			self.loadMarkers(visibleRegionCorners: visibleRegionCorners)
		}
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

extension MainMapViewController: GMUClusterManagerDelegate {
	func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
		let newCamera = GMSCameraPosition.camera(
			withTarget: cluster.position,
			zoom: mapView.camera.zoom + 1
		)
		let update = GMSCameraUpdate.setCamera(newCamera)
		mapView.moveCamera(update)
		return true
	}
}
extension MainMapViewController: GMUClusterRendererDelegate {
	func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
		guard let clusterItem = object as? MapClusterItem, let mapResource = clusterItem.mapResource else { return nil }
		let marker = MapResourceMarker()
		self.setupMarkerInfo(marker: marker, mapResource: mapResource)
		return marker
	}
}