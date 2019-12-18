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
				// do whatever
				print("viewport changed!!!", visibleRegionCorners)
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
	
	private func loadMarkers(visibleRegionCorners: (nearLeft: LocationCoordinate, farRight: LocationCoordinate)) {
		
		//self.markers.forEach { $0.map = nil }
		//self.markers.removeAll(keepingCapacity: true)
		
		var newMarkers: [GMSMarker] = []
		
		self.viewModel.fetchMapResources(
			input: .init(mapFrame: MapFrame(
				lowerLeft: visibleRegionCorners.nearLeft,
				upperRight: visibleRegionCorners.farRight
			)),
			completionHandler: {
				
				guard let places = (try? $0.get())?.mapResource else { return }
				
				// todo
				let first10Places = places.count > 10 ? Array(places[0..<10]) : places
				
				DispatchQueue.concurrentPerform(iterations: first10Places.count) { (index) in
					DispatchQueue.main.async {
						let place = first10Places[index]
						let position = CLLocationCoordinate2D(latitude: place.y, longitude: place.x)
						guard !self.markers.contains(where: { $0.position == position}) else { return }
						let marker = GMSMarker()
						marker.position = CLLocationCoordinate2D(latitude: place.y, longitude: place.x)
						marker.title = place.placeName
						//marker.map = self.mapView
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
