import Foundation

@MainActor
final class CodingSessionStore: ObservableObject {
    @Published var terminals: [TerminalSession] = [.init(), .init(), .init()]
    @Published var activeTerminal = 0
    @Published var isConnected = true

    private var streamTask: Task<Void, Never>?

    func sendMessage(_ text: String) async {
        let idx = activeTerminal
        let userMsg = TerminalMessage(role: .user, content: text, timestamp: .now)
        terminals[idx].messages.append(userMsg)
        terminals[idx].isStreaming = true
        terminals[idx].currentResponse = ""

        var accumulated = ""

        do {
            let body: [String: Any] = ["terminal": idx, "text": text]
            let bodyData = try JSONSerialization.data(withJSONObject: body)

            guard let url = await Self.resolveURL(path: PiConstants.codingMessagePath) else {
                terminals[idx].isStreaming = false
                isConnected = false
                appendError(to: idx, message: "Cannot reach Pi")
                return
            }

            isConnected = true
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData
            request.timeoutInterval = 300 // Long timeout for Claude responses

            let (bytes, response) = try await URLSession.shared.bytes(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                terminals[idx].isStreaming = false
                appendError(to: idx, message: "Server error")
                return
            }

            for try await line in bytes.lines {
                guard !line.isEmpty else { continue }
                guard let data = line.data(using: .utf8),
                      let event = try? JSONDecoder().decode(StreamEvent.self, from: data) else {
                    continue
                }

                switch event.type {
                case "delta":
                    if let text = event.text {
                        accumulated += text
                        terminals[idx].currentResponse = accumulated
                    }
                case "tool":
                    let toolName = event.name ?? "tool"
                    accumulated += "\n> Using \(toolName)...\n"
                    terminals[idx].currentResponse = accumulated
                case "error":
                    let errMsg = event.message ?? "Unknown error"
                    accumulated += "\n[Error: \(errMsg)]\n"
                    terminals[idx].currentResponse = accumulated
                case "done":
                    break
                default:
                    break
                }
            }
        } catch {
            if accumulated.isEmpty {
                appendError(to: idx, message: error.localizedDescription)
            }
        }

        // Finalize: move accumulated text into a message
        if !accumulated.isEmpty {
            let msg = TerminalMessage(role: .assistant, content: accumulated, timestamp: .now)
            terminals[idx].messages.append(msg)
        }
        terminals[idx].currentResponse = ""
        terminals[idx].isStreaming = false
    }

    func clearTerminal(_ index: Int) async {
        terminals[index] = TerminalSession()

        // Tell the Pi to clear the session
        guard let url = await Self.resolveURL(path: "\(PiConstants.codingClearPath)/\(index)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = PiConstants.requestTimeout
        _ = try? await URLSession.shared.data(for: request)
    }

    private func appendError(to idx: Int, message: String) {
        let msg = TerminalMessage(role: .assistant, content: "[Error: \(message)]", timestamp: .now)
        terminals[idx].messages.append(msg)
    }

    /// Try local IP, then Tailscale. Returns first reachable URL.
    private static func resolveURL(path: String) async -> URL? {
        for baseURL in [PiConstants.localBaseURL, PiConstants.tailscaleBaseURL] {
            if let url = URL(string: "\(baseURL)\(path)") {
                // Quick connectivity check for streaming endpoints
                return url
            }
        }
        return nil
    }
}
