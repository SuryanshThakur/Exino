import SwiftUI

/// Represents a message in the console output
struct ConsoleMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: MessageType
    let timestamp: Date = Date()
    
    enum MessageType: String, CaseIterable {
        case info = "INFO"
        case success = "SUCCESS"
        case warning = "WARNING"
        case error = "ERROR"
        case command = "COMMAND"
        case output = "OUTPUT"
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            case .command: return .purple
            case .output: return .primary
            }
        }
    }
    
    init(text: String, type: MessageType = .info) {
        self.text = text
        self.type = type
    }
}
