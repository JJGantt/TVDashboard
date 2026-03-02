import SwiftUI

struct TerminalPanesView: View {
    @ObservedObject var store: CodingSessionStore

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { idx in
                    TerminalPane(
                        index: idx,
                        session: store.terminals[idx],
                        isActive: idx == store.activeTerminal
                    ) {
                        store.activeTerminal = idx
                    }
                    .frame(width: paneWidth(for: idx, totalWidth: geo.size.width))
                    .animation(.easeInOut(duration: 0.3), value: store.activeTerminal)
                }
            }
        }
    }

    private func paneWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 4
        let available = totalWidth - spacing
        return index == store.activeTerminal ? available * 0.5 : available * 0.25
    }
}

private struct TerminalPane: View {
    let index: Int
    let session: TerminalSession
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                PaneHeader(index: index, session: session, isActive: isActive)
                PaneContent(session: session, isActive: isActive)
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.green.opacity(0.4) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PaneButtonStyle())
    }
}

private struct PaneHeader: View {
    let index: Int
    let session: TerminalSession
    let isActive: Bool

    var body: some View {
        HStack {
            Text("T\(index + 1)")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(isActive ? .bold : .regular)
                .foregroundStyle(isActive ? .green : .gray)

            if session.isStreaming {
                ProgressView()
                    .scaleEffect(0.5)
            }

            Spacer()

            if !session.messages.isEmpty {
                Text("\(session.messages.count)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Color.green.opacity(0.1) : Color.white.opacity(0.03))
    }
}

private struct PaneContent: View {
    let session: TerminalSession
    let isActive: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(session.messages) { msg in
                        PaneMessage(message: msg, isCompact: !isActive)
                    }

                    if session.isStreaming && !session.currentResponse.isEmpty {
                        Text(session.currentResponse)
                            .font(.system(isActive ? .body : .caption, design: .monospaced))
                            .foregroundStyle(.green)
                            .id("streaming")
                    }

                    if session.isStreaming && session.currentResponse.isEmpty {
                        Text("Thinking...")
                            .font(.system(isActive ? .body : .caption, design: .monospaced))
                            .foregroundStyle(.green.opacity(0.5))
                            .id("loading")
                    }

                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(isActive ? 16 : 8)
            }
            .onChange(of: session.messages.count) {
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: session.currentResponse) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
}

private struct PaneMessage: View {
    let message: TerminalMessage
    let isCompact: Bool

    var body: some View {
        if message.role == .user {
            Text("> \(message.content)")
                .font(.system(isCompact ? .caption : .body, design: .monospaced))
                .foregroundStyle(.white)
                .lineLimit(isCompact ? 2 : nil)
        } else {
            Text(message.content)
                .font(.system(isCompact ? .caption : .body, design: .monospaced))
                .foregroundStyle(.green)
                .lineLimit(isCompact ? 4 : nil)
        }
    }
}

private struct PaneButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
