//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	struct FeedImageRemoteList: Decodable {}

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
