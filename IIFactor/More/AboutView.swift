import SwiftUI

struct AboutView: View {

    var body: some View {
        VStack {
            LinkCardView(heading: "Source Code", message: "https://github.com/Plus1XP/II-Factor")
        }
    }
}

private struct LinkCardView: View {

        let heading: String
        let message: String

        var body: some View {
                VStack {
                        HStack {
                                Text(NSLocalizedString(heading, comment: .empty)).font(.headline)
                                Spacer()
                        }
                        HStack {
                                Text(NSLocalizedString(message, comment: .empty)).font(.system(.footnote, design: .monospaced))
                                Spacer()
                        }
                }
                .contextMenu(menuItems: {
                        MenuCopyButton(message)
                })
        }
}
