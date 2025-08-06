import Foundation

struct Container: Identifiable, Codable, Hashable, Equatable {
    static func == (lhs: Container, rhs: Container) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id = UUID()
    var name: String
    var path: String
    var wineVersion: String
    var createdAt: Date
    var isDefault: Bool = false
    
    // Default container path in user's home directory
    static let defaultContainersPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("ExinoContainers")
        .path
        
    var fullPath: String {
        return "\(Container.defaultContainersPath)/\(name)"
    }
}
