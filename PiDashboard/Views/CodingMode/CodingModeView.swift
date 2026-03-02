import SwiftUI

struct CodingModeView: View {
    @StateObject private var store = CodingSessionStore()
    @StateObject private var voice = VoiceInputManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                TerminalTabBar(
                    activeIndex: $store.activeTerminal,
                    terminals: store.terminals
                )

                TerminalView(session: store.terminals[store.activeTerminal])
                    .frame(maxHeight: .infinity)

                CodingStatusBar(
                    isConnected: store.isConnected,
                    isRecording: voice.isRecording,
                    interimText: voice.interimText,
                    activeTerminal: store.activeTerminal
                )
            }
        }
        .alert("Send Message", isPresented: $voice.showTextInput) {
            TextField("Type or dictate...", text: $voice.textInput)
            Button("Send") {
                let text = voice.textInput.trimmingCharacters(in: .whitespacesAndNewlines)
                voice.textInput = ""
                if !text.isEmpty {
                    Task { await store.sendMessage(text) }
                }
            }
            Button("Cancel", role: .cancel) {
                voice.textInput = ""
            }
        }
        .onPlayPauseCommand {
            handlePlayPause()
        }
        .onMoveCommand { direction in
            switch direction {
            case .left:
                store.activeTerminal = max(0, store.activeTerminal - 1)
            case .right:
                store.activeTerminal = min(2, store.activeTerminal + 1)
            default:
                break
            }
        }
    }

    private func handlePlayPause() {
        if voice.isRecording {
            voice.stopRecording()
            Task {
                let text = await voice.transcribeAudio()
                if !text.isEmpty {
                    await store.sendMessage(text)
                }
            }
        } else {
            voice.toggleRecording()
        }
    }
}
