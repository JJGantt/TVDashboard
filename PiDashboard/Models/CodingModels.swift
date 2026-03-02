import Foundation

struct TerminalMessage: Identifiable {
    let id = UUID()
    let role: Role
    var content: String
    let timestamp: Date

    enum Role {
        case user, assistant
    }
}

struct TerminalSession {
    var messages: [TerminalMessage] = []
    var isStreaming = false
    var currentResponse = ""
}

struct StreamEvent: Decodable {
    let type: String      // "delta", "done", "error", "tool"
    let text: String?
    let message: String?
    let name: String?     // tool name for "tool" events
}
