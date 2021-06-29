import SwiftUI

struct AboutView: View {

    var body: some View {
        VStack {
//            VersionLabel()
            LinkCardView(heading: "Source Code", message: "https://github.com/plus1xp/authenticator")
            LinkCardView(heading: "Forked From", message: "https://github.com/ososoio/authenticator")
        }
    }
}

private struct VersionLabel: View {

        private let versionString: String = {
                let version: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "_error"
                let build: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "_error"
                return version + " (" + build + ")"
        }()

        var body: some View {
            VStack {
                HStack {
                        Text("Version")
                            .font(.headline)
                        Spacer()
                        Text(versionString)
                }
                .fillBackground()
                .contextMenu(menuItems: {
                        MenuCopyButton(content: versionString)
                })
                .padding(.bottom)
        }
            
        }
}
private struct LinkCardView: View {

        let heading: String
        let message: String

        var body: some View {
                VStack {
                        HStack {
                                Text(NSLocalizedString(heading, comment: "")).font(.headline)
                                Spacer()
                        }
                        HStack {
                                Text(NSLocalizedString(message, comment: "")).font(.system(.footnote, design: .monospaced))
                                Spacer()
                        }
                }
                .padding(.bottom)
                .fillBackground()
                .contextMenu(menuItems: {
                        MenuCopyButton(content: message)
                })
        }
}
