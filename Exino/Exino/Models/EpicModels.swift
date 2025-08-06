import Foundation

// Represents an entitlement from the Epic Games API
struct EpicEntitlement: Codable, Identifiable {
    let id: String
    let entitlementName: String
    let namespace: String
    let catalogItemId: String
    let grantDate: String
    let status: String
}

// Represents a game from the Epic Games Library
struct EpicGame: Identifiable {
    let id: String // catalogItemId
    let name: String
    let namespace: String
    var description: String?
    var keyImages: [KeyImage]?
}

struct KeyImage: Codable, Hashable {
    let type: String
    let url: String
}

struct CatalogItem: Codable {
    let id: String
    let title: String
    let description: String
    let longDescription: String?
    let keyImages: [KeyImage]
}
