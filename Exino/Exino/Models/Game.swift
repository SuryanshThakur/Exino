import Foundation

struct Game: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var executablePath: String
    var client: GameClient?
    var isRunning: Bool = false
    
    init(id: UUID = UUID(), name: String, executablePath: String, client: GameClient? = nil) {
        self.id = id
        self.name = name
        self.executablePath = executablePath
        self.client = client
    }
    
    // Implement Equatable
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}

// Sample data for previews
extension Game {
    static let sampleGames: [Game] = [
        Game(name: "Sample Game 1", executablePath: "/path/to/game1.exe"),
        Game(name: "Sample Game 2", executablePath: "/path/to/game2.exe")
    ]
}
