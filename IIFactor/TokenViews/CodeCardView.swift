import SwiftUI

struct CodeCardView: View {

        let token: Token
        var index: Int
        @Binding var totp: String
        @Binding var timeRemaining: Int
        @Binding var isPresented: Bool
        @State private var isBannerPresented: Bool = false

        private let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
    
        var body: some View {
                VStack {
                        HStack(spacing: 16) {
                                issuerImage.resizable().scaledToFit().frame(width: 24, height: 24)
                                Text(verbatim: token.displayIssuer).font(.headline)
                                Spacer()
                                Menu {
                                    Button(action: {
                                        tokenIndex = index
                                        presentingSheet = .cardDetailView
                                        isPresented = true
                                    }) {
                                        Label("View Details", systemImage: "text.justifyleft")
                                    }
                                    Button(action: {
                                        tokenIndex = index
                                        presentingSheet = .cardEditing
                                        isPresented = true
                                    }) {
                                        Label("Edit Details", systemImage: "square.and.pencil")
                                    }
                                } label: {
                                        Image(systemName: "ellipsis.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.primary)
                                                .padding(.leading, 8)
                                                .contentShape(Rectangle())
                                }
                        }
                        VStack(spacing: 8) {
                                HStack {
                                        Text(verbatim: formattedTotp).font(.largeTitle)
                                        Spacer()
                                }
                                HStack {
                                    Text(token.displayAccountName).font(.footnote)
                                    Spacer()
                                    ZStack {
                                        Circle().stroke(Color.primary.opacity(0.2), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        Arc(startAngle: .degrees(-90), endAngle: .degrees(endAngle), clockwise: true)
                                            .stroke(lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(ArcColor(timeRemaining: timeRemaining))
                                        Text(timeRemaining.description).font(.footnote)
                                        }
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                                UIPasteboard.general.string = totp
                                isBannerPresented = true
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    feedbackGenerator?.notificationOccurred(.success)
                                    self.isBannerPresented = false
                                }
                        }
                }
                .padding()
                .fillBackground()
                .modifier(BannerModifier(isPresented: $isBannerPresented))
        }

        private var formattedTotp: String {
                var code: String = totp
                switch code.count {
                case 6:
                        code.insert(" ", at: code.index(code.startIndex, offsetBy: 3))
                case 8:
                        code.insert(" ", at: code.index(code.startIndex, offsetBy: 4))
                default:
                        break
                }
                return code
        }

        ///  The  Guard statement has a Ternary Operator within, which checks if the displayIssuer (imageName) contains a white space.
        ///  If the value  does contain a white space, it will remove the white spaces from the string and attempt to return a logo from Images.
        ///  If the value does not contain a white space, it will attempt to return a logo from Images.
        ///  If either of the values returns nil (there is no logo matching imageName) the guard is invoked and will finally return a default system image.
        private var issuerImage: Image {
                let imageName: String = token.displayIssuer.lowercased()
                guard let uiImage: UIImage = imageName.contains(" ") ? UIImage(named: imageName.removeSpaces()) : (UIImage(named: imageName)) else { return Image(systemName: "person.circle") }
                return Image(uiImage: uiImage)
        }

        private var endAngle: Double { Double((30 - timeRemaining) * 12 - 89) }
    
        private func ArcColor(timeRemaining: Int) -> Color {
            switch timeRemaining {
            case 22...:
                return Color.blue
            case 14..<22:
                return Color.green
            case 7..<14:
                return Color.yellow
            case timeRemaining ..< 7:
                return Color.red
            default:
                return Color.primary
            }
        }
}

private struct Arc: Shape {
        let startAngle: Angle
        let endAngle: Angle
        let clockwise: Bool
        func path(in rect: CGRect) -> Path {
                var path = Path()
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
                return path
        }
}

private struct BannerModifier: ViewModifier {

        @Binding var isPresented: Bool

        func body(content: Content) -> some View {
                ZStack {
                        content.zIndex(0)
                        if isPresented {
                                BannerView().zIndex(1)
                            }
                }
        }
}

private struct BannerView: View {
        var body: some View {
                Text("Copied")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 40)
                        .background(BlurView())
                        .clipShape(RoundedRectangle(cornerRadius: 12))
        }
}

private struct BlurView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIVisualEffectView {
                return UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
                uiView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
}
