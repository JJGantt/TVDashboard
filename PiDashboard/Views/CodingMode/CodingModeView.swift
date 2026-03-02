import SwiftUI

struct CodingModeView: View {
    @StateObject private var store = CodingSessionStore()
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TerminalPanesView(store: store)

                CodingStatusBar(
                    isConnected: store.isConnected,
                    activeTerminal: store.activeTerminal,
                    isStreaming: store.terminals[store.activeTerminal].isStreaming
                )
            }
            .background(Color.black)
            .searchable(text: $inputText, prompt: "Tap mic to dictate...")
            .onSubmit(of: .search) {
                sendIfNonEmpty()
            }
            .onChange(of: inputText) { _, newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                // Dictation dumps text all at once — auto-send
                inputText = ""
                Task { await store.sendMessage(trimmed) }
            }
        }
    }

    private func sendIfNonEmpty() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        guard !trimmed.isEmpty else { return }
        Task { await store.sendMessage(trimmed) }
    }
}
