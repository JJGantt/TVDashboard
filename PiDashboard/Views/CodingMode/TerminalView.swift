import SwiftUI

struct TerminalView: View {
    let session: TerminalSession

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(session.messages) { msg in
                        MessageBubble(message: msg)
                    }

                    if session.isStreaming && !session.currentResponse.isEmpty {
                        Text(session.currentResponse)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.green)
                            .id("streaming")
                    }

                    if session.isStreaming && session.currentResponse.isEmpty {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Thinking...")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.green.opacity(0.6))
                        }
                        .id("loading")
                    }

                    // Anchor for scroll-to-bottom
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(40)
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
        .background(Color.black)
    }
}

private struct MessageBubble: View {
    let message: TerminalMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if message.role == .user {
                Text("> \(message.content)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)
            } else {
                Text(message.content)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.green)
            }
        }
    }
}
