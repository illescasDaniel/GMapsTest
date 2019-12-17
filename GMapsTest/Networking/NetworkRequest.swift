//
//  NetworkRequest.swift
//  GMapsTest
//
//  Created by Daniel Illescas Romero on 17/12/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Alamofire
import Foundation

protocol NetworkRequestBuilder {
    
    var baseURL: String { get }
    var path: String { get }
    
    var httpHeaders: HTTPHeaders? { get }
    var httpMethod: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    
    var body: Data? { get }
}
extension NetworkRequestBuilder {
	
	var httpHeaders: HTTPHeaders? { nil}
	var queryItems: [URLQueryItem]? { nil }
	var body: Data? { nil }
	
    func asURLRequest() -> Result<URLRequestConvertible, NetworkRequestBuilderError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
			return .failure(.malformedURL)
		}
        urlComponents.path = self.path
        urlComponents.queryItems = self.queryItems
        guard let url = urlComponents.url else {
			return .failure(.invalidConstructedURL)
		}
		
        var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = self.httpMethod.rawValue
		urlRequest.allHTTPHeaderFields = self.httpHeaders?.dictionary
        urlRequest.httpBody = self.body
		
		return .success(urlRequest)
    }
}

protocol BodyNetworkRequestBuilder: NetworkRequestBuilder {
    associatedtype BodyType: Encodable
    var encodableBody: BodyType { get }
}
extension BodyNetworkRequestBuilder {
	var body: Result<Data, Error> { .init {
		try JSONEncoder().encode(self.encodableBody)
	}}
}
extension BodyNetworkRequestBuilder where Self: Encodable {
    var encodableBody: Self { self }
}
