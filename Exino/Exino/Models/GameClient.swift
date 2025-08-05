import Foundation

enum ClientStatus: String, Codable {
    case installed
    case notInstalled
    case installing
    case error
}

struct GameClient: Identifiable, Codable {
    let id: UUID
    var name: String
    var status: ClientStatus
    var installPath: String?
    
    init(id: UUID = UUID(), name: String, status: ClientStatus = .notInstalled, installPath: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.installPath = installPath
    }
}

// Sample data for previews
extension GameClient {
    static let sampleClients: [GameClient] = [
        GameClient(name: "Steam", status: .notInstalled),
        GameClient(name: "Epic Games", status: .notInstalled),
        GameClient(name: "GOG Galaxy", status: .notInstalled)
    ]
}
