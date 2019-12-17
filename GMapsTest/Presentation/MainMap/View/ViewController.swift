//
//  ViewController.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		// just a test!!
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
			DefaultMapResourcesUseCase(
				mapResourcesRepository: DefaultMapResourcesRepository()
			).execute(
				requestValue: MapResourcesUseCaseValue(mapFrame: MapFrame(
					lowerLeft: .init(latitude: 38, longitude: -9),
					upperRight: .init(latitude: 50, longitude: -20)
				)),
				completionHandler: {
					dump($0)
				}
			)
				
		}
	}

}

