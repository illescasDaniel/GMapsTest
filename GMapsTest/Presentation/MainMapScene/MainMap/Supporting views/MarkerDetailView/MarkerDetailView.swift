//
//  MarkerDetailView.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 19/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class MarkerDetailView: UIView {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	static func create(title: String, subtitle: String) -> MarkerDetailView? {
		let nib = UINib(nibName: "\(MarkerDetailView.self)", bundle: .main)
		guard let view = nib.instantiate(withOwner: nil, options: nil).first as? MarkerDetailView else {
			return nil
		}
		
		view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
		
		view.titleLabel.text = title
		view.subtitleLabel.text = subtitle
		
		view.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		view.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		
		return view
	}
}
