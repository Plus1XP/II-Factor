import SwiftUI

struct MenuCopyButton: View {

        init(_ content: String) {
                self.content = content
        }

        private let content: String

        var body: some View {
                Button(action: {
                        UIPasteboard.general.string = content
                }) {
                        Label("Copy", systemImage: "doc.on.doc")
                }
        }
}
