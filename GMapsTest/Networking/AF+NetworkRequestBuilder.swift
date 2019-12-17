//
//  AF+NetworkRequestBuilder.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation
import Alamofire

extension AF {
	
	// specific convenient function for this project to easily make a request from a "networkRequestBuilder"
	static func networkRequestWithJSONResponse<T: Decodable>(builder networkRequestBuilder: NetworkRequestBuilder, completionHandler: @escaping (Result<T,AFError>) -> Void) {
		switch networkRequestBuilder.asURLRequest() {
		case .success(let urlRequest):
			AF.request(urlRequest)
				.validate(statusCode: 200..<300)
				.validate(contentType: ["application/json"])
				.responseDecodable(of: T.self, queue: .global(), decoder: JSONDecoder()) { dataResponse in
					completionHandler(dataResponse.result)
				}
		case .failure(let networkRequestBuilderError):
			completionHandler(.failure(AFError.createURLRequestFailed(error: networkRequestBuilderError)))
		}
	}
}

