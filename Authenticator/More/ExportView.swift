import SwiftUI
import CoreImage.CIFilterBuiltins

struct ExportView: View {

        let tokens: [Token]

        @State private var isPlainTextActivityPresented: Bool = false
        @State private var isTXTFileActivityPresented: Bool = false
        @State private var isZIPFileActivityPresented: Bool = false

        var body: some View {
                                VStack {
                                        Button(action: {
                                                UIPasteboard.general.string = tokensText
                                        }) {
                                                HStack {
                                                        Text("Copy all Key URIs to Clipboard")
                                                            .padding()
                                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                            .background(Color(UIColor.secondarySystemFill))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                }
                                        }

                                        Button(action: {
                                                isPlainTextActivityPresented = true
                                        }) {
                                                HStack {
                                                    Text("Export all Key URIs as plain text")
                                                        .padding()
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                        .background(Color(UIColor.secondarySystemFill))
                                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                        }
                                        .sheet(isPresented: $isPlainTextActivityPresented) {
                                                ActivityView(activityItems: [tokensText]) {
                                                        isPlainTextActivityPresented = false
                                                }
                                        }

                                        Button(action: {
                                                isTXTFileActivityPresented = true
                                        }) {
                                                HStack {
                                                        Text("Export all Key URIs in .txt file")
                                                            .padding()
                                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                            .background(Color(UIColor.secondarySystemFill))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                }
                                        }
                                        .sheet(isPresented: $isTXTFileActivityPresented) {
                                                let url = txtFile()
                                                #if targetEnvironment(macCatalyst)
                                                DocumentExporter(url: url)
                                                #else
                                                ActivityView(activityItems: [url]) {
                                                        isTXTFileActivityPresented = false
                                                }
                                                #endif
                                        }

                                        Button(action: {
                                                isZIPFileActivityPresented = true
                                        }) {
                                                HStack {
                                                        Text("Export all QR Code images in .zip file")
                                                            .multilineTextAlignment(.center)
                                                            .padding()
                                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                            .background(Color(UIColor.secondarySystemFill))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                            .foregroundColor(.primary)
                                                        Spacer()
                                                }
                                        }
                                        .sheet(isPresented: $isZIPFileActivityPresented) {
                                                let url: URL = zipFile()
                                                #if targetEnvironment(macCatalyst)
                                                DocumentExporter(url: url)
                                                #else
                                                ActivityView(activityItems: [url]) {
                                                        isZIPFileActivityPresented = false
                                                }
                                                #endif
                                        }
                }
        }

        private var tokensText: String {
                return tokens.reduce(.empty) { $0 + $1.uri + "\n" }
        }

        private func txtFile() -> URL {
                let txtFileName: String = "IIFactor-accounts-" + Date.currentDateText + ".txt"
                let txtFileUrl: URL = .tmpDirectoryUrl.appendingPathComponent(txtFileName, isDirectory: false)
                try? tokensText.write(to: txtFileUrl, atomically: true, encoding: .utf8)
                return txtFileUrl
        }

        // https://recoursive.com/2021/02/25/create_zip_archive_using_only_foundation
        private func zipFile() -> URL {
                let imagesDirectoryName: String = "IIFactor-accounts-" + Date.currentDateText
                let imagesDirectoryUrl: URL = .tmpDirectoryUrl.appendingPathComponent(imagesDirectoryName, isDirectory: true)
                if !(FileManager.default.fileExists(atPath: imagesDirectoryUrl.path)) {
                        try? FileManager.default.createDirectory(at: imagesDirectoryUrl, withIntermediateDirectories: false)
                }
                _ = tokens.map { oneToken in
                        _ = saveQRCodeImage(for: oneToken, parent: imagesDirectoryUrl)
                }
                let zipFileUrl: URL = .tmpDirectoryUrl.appendingPathComponent("\(imagesDirectoryName).zip", isDirectory: false)
                let coordinator = NSFileCoordinator()
                var err: NSError?
                coordinator.coordinate(readingItemAt: imagesDirectoryUrl, options: .forUploading, error: &err) { url in
                        try? FileManager.default.moveItem(at: url, to: zipFileUrl)
                }
                return zipFileUrl
        }
        private func saveQRCodeImage(for token: Token, parent parentDirectoryUrl: URL) -> URL? {
                guard let image: UIImage = generateQRCodeImage(from: token) else { return nil }
                let name: String = imageName(for: token)
                let fileUrl: URL = parentDirectoryUrl.appendingPathComponent(name, isDirectory: false)
                do {
                        try image.pngData()?.write(to: fileUrl)
                } catch {
                        return nil
                }
                return fileUrl
        }
        private func generateQRCodeImage(from token: Token) -> UIImage? {
                let filter = CIFilter.qrCodeGenerator()
                let data: Data = Data(token.uri.utf8)
                filter.setValue(data, forKey: "inputMessage")
                filter.setValue("H", forKey: "inputCorrectionLevel")
                let transform: CGAffineTransform = CGAffineTransform(scaleX: 5, y: 5)
                guard let ciImage: CIImage = filter.outputImage?.transformed(by: transform) else { return nil }
                return UIImage(ciImage: ciImage)
        }
        private func imageName(for token: Token) -> String {
                var imageName: String = token.id + "-" + Date.currentDateText + ".png"
                imageName.insert("-", at: imageName.index(imageName.startIndex, offsetBy: token.secret.count))

                if let accountName: String = token.accountName, !accountName.isEmpty {
                        let prefix: String = accountName + "-"
                        imageName.insert(contentsOf: prefix, at: imageName.startIndex)
                }
                if let issuer: String = token.issuer, !issuer.isEmpty {
                        let prefix: String = issuer + "-"
                        imageName.insert(contentsOf: prefix, at: imageName.startIndex)
                }
                return imageName
        }
}
