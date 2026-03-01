import TVServices
import Foundation

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent() async -> TVTopShelfContent? {
        // Minimal test: one section, one item, bundled image
        guard let imageURL = Bundle.main.url(forResource: "placeholder", withExtension: "png") else {
            return nil
        }

        let item = TVTopShelfSectionedItem(identifier: "test-1")
        item.title = "Pi Dashboard"
        item.imageShape = .poster
        item.setImageURL(imageURL, for: .screenScale1x)
        item.setImageURL(imageURL, for: .screenScale2x)

        let collection = TVTopShelfItemCollection(items: [item])
        collection.title = "Test"

        return TVTopShelfSectionedContent(sections: [collection])
    }
}
