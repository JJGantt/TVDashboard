import SwiftUI

struct CodingStatusBar: View {
    let isConnected: Bool
    let isRecording: Bool
    let interimText: String
    let activeTerminal: Int

    var body: some View {
        HStack(spacing: 16) {
            // Connection status
            HStack(spacing: 6) {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(isConnected ? "Connected" : "Offline")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Recording indicator
            if isRecording {
                HStack(spacing: 8) {
                    RecordingDot()
                    Text(interimText.isEmpty ? "Listening..." : interimText)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: 600, alignment: .leading)
            } else {
                Text("Press Play/Pause to speak")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("T\(activeTerminal + 1)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.9))
    }
}

private struct RecordingDot: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 12, height: 12)
            .opacity(isPulsing ? 0.4 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}
