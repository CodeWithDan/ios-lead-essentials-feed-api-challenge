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

		var feedImageList: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	struct FeedImageRemoteItem: Decodable {
		let imageId: UUID
		let imageDesciption: String?
		let imageLocation: String?
		let imageUrl: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDesciption = "image_desc"
			case imageLocation = "image_loc"
			case imageUrl = "image_url"
		}

		var feedImage: FeedImage {
			.init(id: imageId, description: imageDesciption, location: imageLocation, url: imageUrl)
		}
	}

	//MARK:- RemoteFeedLoader

	private let url: URL
	private let client: HTTPClient
	private let validStatus = 200

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		self.client.get(from: url, completion: { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(self.handleSuccessCase(with: data, response: response))
			}
		})
	}

	private func handleSuccessCase(with data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == validStatus,
		      let remoteData = try? JSONDecoder().decode(FeedImageRemoteList.self, from: data)
		else {
			return .failure(Error.invalidData)
		}
		return .success(remoteData.feedImageList)
	}
}
