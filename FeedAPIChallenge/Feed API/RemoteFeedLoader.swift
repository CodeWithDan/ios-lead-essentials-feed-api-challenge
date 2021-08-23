//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	// MARK:- Definition

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	struct FeedImageRemoteList: Decodable {
		let items: [FeedImageRemoteItem]
	}

	struct FeedImageRemoteItem: Decodable {
		let imageId: String
		let imageDesciption: String
		let imageLocation: String
		let imageUrl: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDesciption = "image_desc"
			case imageLocation = "image_loc"
			case imageUrl = "image_url"
		}
	}

	//MARK:- RemoteFeedLoader

	private let url: URL
	private let client: HTTPClient

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		self.client.get(from: url, completion: { result in
			switch result {
			case .failure(_):
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else if let _ = try? JSONDecoder().decode(FeedImageRemoteList.self, from: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		})
	}
}
