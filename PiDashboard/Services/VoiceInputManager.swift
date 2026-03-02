import AVFoundation
import SwiftUI

/// Manages voice/text input for coding mode on tvOS.
///
/// Since SFSpeechRecognizer is not available on tvOS, this captures audio from
/// the Siri Remote microphone and streams it to the Pi for Whisper transcription.
/// Falls back to a text input field with built-in tvOS dictation if audio capture fails.
@MainActor
final class VoiceInputManager: ObservableObject {
    @Published var isRecording = false
    @Published var interimText = ""
    @Published var showTextInput = false
    @Published var textInput = ""

    private let audioEngine = AVAudioEngine()
    private var audioData = Data()
    private var audioAvailable = false

    init() {
        // Check if audio input is available (Siri Remote mic)
        audioAvailable = audioEngine.inputNode.inputFormat(forBus: 0).channelCount > 0
    }

    func toggleRecording() {
        if audioAvailable {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } else {
            // Fall back to text input with built-in tvOS dictation
            showTextInput = true
        }
    }

    func startRecording() {
        audioData = Data()
        let inputNode = audioEngine.inputNode
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                   sampleRate: 16000,
                                   channels: 1,
                                   interleaved: true)!

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            let audioBuffer = buffer.audioBufferList.pointee.mBuffers
            if let data = audioBuffer.mData {
                let byteCount = Int(audioBuffer.mDataByteSize)
                let chunk = Data(bytes: data, count: byteCount)
                Task { @MainActor in
                    self.audioData.append(chunk)
                }
            }
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            interimText = "Listening..."
        } catch {
            isRecording = false
            showTextInput = true  // Fall back to text input
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
        interimText = "Transcribing..."
    }

    /// Send captured audio to Pi for Whisper transcription, return the text.
    func transcribeAudio() async -> String {
        guard !audioData.isEmpty else {
            interimText = ""
            return ""
        }

        // Build WAV file from raw PCM data
        let wavData = buildWAV(pcmData: audioData, sampleRate: 16000, channels: 1, bitsPerSample: 16)

        for baseURL in [PiConstants.localBaseURL, PiConstants.tailscaleBaseURL] {
            guard let url = URL(string: "\(baseURL)/tv/coding/transcribe") else { continue }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
            request.httpBody = wavData
            request.timeoutInterval = 30

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { continue }
                if let json = try? JSONDecoder().decode([String: String].self, from: data),
                   let text = json["text"], !text.isEmpty {
                    interimText = ""
                    audioData = Data()
                    return text
                }
            } catch {
                continue
            }
        }

        // Transcription failed — fall back to showing text input
        interimText = ""
        audioData = Data()
        showTextInput = true
        return ""
    }

    private func buildWAV(pcmData: Data, sampleRate: Int, channels: Int, bitsPerSample: Int) -> Data {
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8
        let dataSize = pcmData.count
        let fileSize = 36 + dataSize

        var wav = Data()
        wav.append(contentsOf: "RIFF".utf8)
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(fileSize).littleEndian) { Array($0) })
        wav.append(contentsOf: "WAVE".utf8)
        wav.append(contentsOf: "fmt ".utf8)
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) })  // PCM
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(channels).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(blockAlign).littleEndian) { Array($0) })
        wav.append(contentsOf: withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Array($0) })
        wav.append(contentsOf: "data".utf8)
        wav.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })
        wav.append(pcmData)
        return wav
    }
}
