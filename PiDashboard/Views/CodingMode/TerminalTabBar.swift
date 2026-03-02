import SwiftUI

struct TerminalTabBar: View {
    @Binding var activeIndex: Int
    let terminals: [TerminalSession]

    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { idx in
                TerminalTab(
                    index: idx,
                    isActive: idx == activeIndex,
                    hasMessages: !terminals[idx].messages.isEmpty,
                    isStreaming: terminals[idx].isStreaming
                )
            }
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.8))
    }
}

private struct TerminalTab: View {
    let index: Int
    let isActive: Bool
    let hasMessages: Bool
    let isStreaming: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Text("Terminal \(index + 1)")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(isActive ? .green : .gray)

                if hasMessages {
                    Circle()
                        .fill(isStreaming ? Color.yellow : Color.green)
                        .frame(width: 8, height: 8)
                }
            }

            Rectangle()
                .fill(isActive ? Color.green : Color.clear)
                .frame(height: 2)
        }
    }
}
