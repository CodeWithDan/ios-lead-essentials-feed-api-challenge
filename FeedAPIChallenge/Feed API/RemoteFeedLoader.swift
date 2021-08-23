//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private let url: URL
	private let client: HTTPClient

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		self.client.get(from: url, completion: { [weak self] result in
			if self == nil { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(FeedImagesMapper.handleSuccessCase(with: data, from: response))
			}
		})
	}
}
