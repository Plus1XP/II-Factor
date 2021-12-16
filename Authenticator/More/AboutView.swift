import SwiftUI

struct AboutView: View {

    var body: some View {
        VStack {
//            VersionLabel()
            LinkCardView(heading: "Source Code", message: "https://github.com/plus1xp/authenticator")
                .padding(.bottom)
            LinkCardView(heading: "Forked From", message: "https://github.com/ososoio/authenticator")
        }
    }
}

private struct VersionLabel: View {

        private let version: String = {
                let versionString: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "_error"
                let buildString: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "_error"
                return versionString + " (" + buildString + ")"
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
                                Text(NSLocalizedString(heading, comment: .empty)).font(.headline)
                                Spacer()
                        }
                        HStack {
                                Text(NSLocalizedString(message, comment: .empty)).font(.system(.footnote, design: .monospaced))
                                Spacer()
                        }
                }
                #if targetEnvironment(macCatalyst)
                .textSelection(.enabled)
                #endif
                .contextMenu(menuItems: {
                        MenuCopyButton(content: message)
                })
        }
}
