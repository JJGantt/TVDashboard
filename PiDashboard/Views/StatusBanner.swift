import SwiftUI

struct StatusBanner: View {
    let isConnected: Bool
    let lastUpdated: String

    var body: some View {
        HStack {
            Image(systemName: isConnected ? "wifi" : "wifi.slash")
                .foregroundStyle(isConnected ? .green : .red)

            Text(isConnected ? "Connected to Pi" : "Offline — showing cached data")
                .font(.callout)
                .foregroundColor(isConnected ? .secondary : .red)

            Spacer()

            if !lastUpdated.isEmpty {
                Text("Updated: \(lastUpdated)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
