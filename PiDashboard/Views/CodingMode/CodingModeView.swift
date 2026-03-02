import SwiftUI

struct CodingModeView: View {
    @StateObject private var store = CodingSessionStore()
    @State private var searchText = ""
    @State private var showExpanded = false
    @State private var showSessionPicker = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                TerminalPanesView(
                    store: store,
                    onExpand: { showExpanded = true },
                    onSessionSwitch: { idx in
                        store.activeTerminal = idx
                        showSessionPicker = true
                    }
                )
            }
        }
        .searchable(text: $searchText, prompt: "Dictate or type...")
        .overlay(alignment: .top) {
            if store.searchBarFocused {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(height: 58)
                    .padding(.horizontal, 20)
                    .allowsHitTesting(false)
            }
        }
        .task { await store.restoreSavedSessions() }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showExpanded) {
            ExpandedTerminalView(session: store.terminals[store.activeTerminal])
        }
        .navigationDestination(isPresented: $showSessionPicker) {
            SessionPickerView(store: store, terminal: store.activeTerminal)
        }
        .onChange(of: store.searchBarFocused) { oldValue, newValue in
            // Focus left search bar (went down to panes) — send text if any
            if oldValue && !newValue {
                let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                searchText = ""
                Task { await store.sendMessage(trimmed) }
            }
        }
    }
}

// MARK: - Expanded Terminal View

private struct ExpandedTerminalView: View {
    let session: TerminalSession

    private var chunks: [(id: String, text: String, isUser: Bool)] {
        var result: [(id: String, text: String, isUser: Bool)] = []
        for msg in session.messages {
            if msg.role == .user {
                result.append((id: msg.id.uuidString, text: "> \(msg.content)", isUser: true))
            } else {
                let paragraphs = msg.content.components(separatedBy: "\n\n")
                for (i, para) in paragraphs.enumerated() where !para.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    result.append((id: "\(msg.id.uuidString)-\(i)", text: para, isUser: false))
                }
            }
        }
        return result
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(chunks, id: \.id) { chunk in
                    Button {} label: {
                        Text(chunk.text)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(chunk.isUser ? .white : .green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(ChunkButtonStyle())
                }
            }
            .padding(40)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

private struct ChunkButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 1)
                .fill(isFocused ? Color.green : Color.clear)
                .frame(width: 3)

            configuration.label
        }
    }
}
