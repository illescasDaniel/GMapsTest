//
//  NetworkRequestBuilderError.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

enum NetworkRequestBuilderError: Error {
	case malformedURL
	/// This error can occur when you forget to prepend slashes "/" to the path variable of a URLComponent
	case invalidConstructedURL
}
