import Foundation
import GRDB

struct ScriptureEntity: Decodable, Equatable {
    let title: String
    let hymnType: HymnType
    let hymnNumber: String
    let queryParams: [String: String]?
    let scriptures: String

    enum CodingKeys: String, CodingKey {
        case title = "SONG_TITLE"
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case queryParams = "QUERY_PARAMS"
        case scriptures = "SONG_META_DATA_SCRIPTURES"
    }
}

extension ScriptureEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        queryParams = try container.decode(String.self, forKey: .queryParams).deserializeFromQueryParamString
        scriptures = try container.decode(String.self, forKey: .scriptures)
    }
}