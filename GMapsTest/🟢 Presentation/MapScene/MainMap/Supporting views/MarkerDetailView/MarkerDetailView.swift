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
	@IBOutlet weak var bodyLabel: UITextView!
	
	static func create(withBounds bounds: CGRect, title: String, body: NSAttributedString) -> MarkerDetailView? {

		let nib = UINib(nibName: "\(MarkerDetailView.self)", bundle: .main)
		guard let view = nib.instantiate(withOwner: nil, options: nil).first as? MarkerDetailView else {
			return nil
		}
		
		view.backgroundColor = UIColor.white.withAlphaComponent(0.93)

		let shapeLayer = CAShapeLayer()
		shapeLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: .init(width: 14, height: 14)).cgPath
		view.layer.mask = shapeLayer

		view.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline).withSize(17)
		view.titleLabel.numberOfLines = 3
		view.titleLabel.adjustsFontSizeToFitWidth = true
		view.titleLabel.minimumScaleFactor = 0.5

		view.bodyLabel.backgroundColor = .clear

		view.titleLabel.text = title
		view.bodyLabel.attributedText = body

		view.bounds = bounds

		return view
	}
}
