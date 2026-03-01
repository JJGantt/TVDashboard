import SwiftUI

struct SectionView: View {
    let section: SectionData
    @Binding var selectedItem: String?

    private var sectionColor: Color {
        switch section.id {
        case "todo": return .blue
        case "grocery": return .green
        case "reminders": return .orange
        case "activity": return .purple
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Circle()
                    .fill(sectionColor)
                    .frame(width: 12, height: 12)
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(section.items.count) items")
                    .foregroundStyle(.secondary)
            }

            if section.items.isEmpty {
                Text("No items")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 30) {
                        ForEach(section.items) { item in
                            NavigationLink(value: item) {
                                ItemCardLabel(item: item, color: sectionColor)
                            }
                            .buttonStyle(.card)
                        }
                    }
                }
            }
        }
    }
}

struct ItemCardLabel: View {
    let item: ItemData
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(width: 300, height: 180)
        .padding(20)
        .background(color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ItemDetailView: View {
    let item: ItemData

    private var sectionColor: Color {
        if item.id.hasPrefix("todo") { return .blue }
        if item.id.hasPrefix("grocery") { return .green }
        if item.id.hasPrefix("reminders") { return .orange }
        if item.id.hasPrefix("activity") { return .purple }
        return .gray
    }

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundStyle(sectionColor)

            Text(item.title)
                .font(.title)
                .multilineTextAlignment(.center)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(60)
    }

    private var iconName: String {
        if item.id.hasPrefix("todo") { return "checklist" }
        if item.id.hasPrefix("grocery") { return "cart" }
        if item.id.hasPrefix("reminders") { return "bell" }
        if item.id.hasPrefix("activity") { return "message" }
        return "doc"
    }
}
