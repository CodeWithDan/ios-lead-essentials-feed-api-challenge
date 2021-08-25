//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

enum FeedImagesMapper {
	private static let validStatus = 200

	private struct FeedImageRemoteList: Decodable {
		let items: [FeedImageRemoteItem]

		var feedImageList: [FeedImage] {
			items.map { $0.feedImage }
		}
	}

	private struct FeedImageRemoteItem: Decodable {
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

	static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == validStatus,
		      let remoteData = try? JSONDecoder().decode(FeedImageRemoteList.self, from: data)
		else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		return .success(remoteData.feedImageList)
	}
}
