import SwiftUI

struct ContentView: View {
    @ObservedObject var store: DashboardStore
    @Binding var selectedSection: String?
    @Binding var selectedItem: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    StatusBanner(isConnected: store.isConnected, lastUpdated: store.lastUpdated)

                    ForEach(store.sections) { section in
                        SectionView(section: section, selectedItem: $selectedItem)
                    }
                }
                .padding(60)
            }
            .navigationTitle("Pi Dashboard")
            .navigationDestination(for: ItemData.self) { item in
                ItemDetailView(item: item)
            }
        }
    }
}
