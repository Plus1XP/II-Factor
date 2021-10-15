import SwiftUI
import CoreData

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var settings: SettingsStore
    
    @FetchRequest(fetchRequest: TokenData.PersonalResults)
    var fetchedTokensPeronal: FetchedResults<TokenData>

    @FetchRequest(fetchRequest: TokenData.WorkResults)
    var fetchedTokensWork: FetchedResults<TokenData>

    @FetchRequest(fetchRequest: TokenData.AllResults)
    var fetchedTokensAll: FetchedResults<TokenData>
    
    @FetchRequest(
        entity: TokenData.entity(),
        sortDescriptors: [NSSortDescriptor(key: "indexNumber", ascending: true)],
        animation: .default) var fetchedTokens: FetchedResults<TokenData>
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining: Int = 30 - (Int(Date().timeIntervalSince1970) % 30)
    @State private var codes: [String] = Array(repeating: "000000", count: 50)
    @State private var isSheetPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedTokens = Set<TokenData>()
    @State private var indexSetOnDelete: IndexSet = IndexSet()
    @State private var isDeletionAlertPresented: Bool = false
    @State private var canEditGroup: Bool = false
    @State private var searchText: String = ""
    
    private var tokenGroupPicker = TokenGroupPicker()
    
    private var tokenGroupSelected: Binding<String> {
        Binding<String>(get: {
            return settings.config!.defaultTokenGroup!
        }, set: {
            settings.config?.defaultTokenGroup = $0
            settings.saveGlobalSettings(viewContext)
            settings.fetchGlobalSettings(viewContext)
        })
    }
    
    private var tokenViewSelected: Binding<TokenGroupType> {
        Binding<TokenGroupType>(get: {
            return tokenGroupPicker.GetTokenGroupValues(tokenGroup: settings.config?.defaultView)
        }, set: {
            settings.config?.defaultView = tokenGroupPicker.GetTokenGroupNames(tokenGroup: $0)
            settings.saveGlobalSettings(viewContext)
            settings.fetchGlobalSettings(viewContext)
        })
    }
    
    var body: some View {
        NavigationView {
            List(selection: $selectedTokens) {
                ForEach(fetchedTokens.filter({ $0.displayGroup == tokenGroupPicker.FilterToken(selectedTokenGroup: tokenViewSelected.wrappedValue) ?? $0.displayGroup }).filter({ searchText.isEmpty ? true : ($0.displayIssuer ?? "").lowercased().contains(searchText.lowercased()) }), id: \.self) { item in
                    let index: Int = Int(fetchedTokens.firstIndex(of: item) ?? 0)
                    if editMode == .active {
                        CodeCardView(token: token(of: item), index: index, totp: $codes[index], timeRemaining: $timeRemaining, isPresented: $isSheetPresented)
                    } else {
                        ZStack {
                            GlobalBackgroundColor()
                            CodeCardView(token: token(of: item), index: index, totp: $codes[index], timeRemaining: $timeRemaining, isPresented: $isSheetPresented)
                                .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .onMove(perform: move(from:to:))
                .onDelete(perform: deleteItems)
            }
            .navigationBarSearch(self.$searchText)
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                generateCodes()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                generateCodes()
                clearTemporaryDirectory()
            }
            .onReceive(timer) { _ in
                timeRemaining = 30 - (Int(Date().timeIntervalSince1970) % 30)
                if timeRemaining == 30 {
                    generateCodes()
                }
            }
            .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.text, .image], allowsMultipleSelection: false) { result in
                    switch result {
                    case .failure(let error):
                            logger.debug(".fileImporter() failure: \(error.localizedDescription)")
                    case .success(let urls):
                            guard let pickedUrl: URL = urls.first else { return }
                            guard pickedUrl.startAccessingSecurityScopedResource() else { return }
                            let cachePathComponent = Date.currentDateText + pickedUrl.lastPathComponent
                            let tmpDirectoryUrl: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                            let cacheUrl: URL = tmpDirectoryUrl.appendingPathComponent(cachePathComponent)
                            try? FileManager.default.copyItem(at: pickedUrl, to: cacheUrl)
                            pickedUrl.stopAccessingSecurityScopedResource()
                            handlePickedFile(url: cacheUrl)
                    }
            }
            .alert(isPresented: $isDeletionAlertPresented) {
                deletionAlert
            }
            .actionSheet(isPresented: $canEditGroup) {
                        ActionSheet(
                            title: Text("Token Group"),
                            message: Text("Select Token Group"),
                            buttons: [
                                .default(Text("None"), action: {
                                    SetSelectedTokengroups(selectedTokenGroup: TokenGroupType.None.rawValue)
                                }),
                                .default(Text("Personal"), action: {
                                    SetSelectedTokengroups(selectedTokenGroup: TokenGroupType.Personal.rawValue)
                                }),
                                .default(Text("Work"), action: {
                                    SetSelectedTokengroups(selectedTokenGroup: TokenGroupType.Work.rawValue)
                                }),
                                .destructive(Text("Cancel"), action: {
                                    canEditGroup = false
                                    selectedTokens.removeAll()
                                })
                            ]
                        )
                    }
            .navigationTitle(tokenGroupPicker.GetTokenGroupNames(tokenGroup: tokenViewSelected.wrappedValue))
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    TokenGroupPickerView(selectedTokenGroup: tokenViewSelected)
                    Spacer()
                    Button {
                        if editMode == .inactive {
                            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                            feedbackGenerator?.notificationOccurred(.success)
                            selectedTokens.removeAll()
                            indexSetOnDelete.removeAll()
                            editMode = .active
                        }
                        else if editMode == .active {
                            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                            feedbackGenerator?.notificationOccurred(.warning)
                            selectedTokens.removeAll()
                            indexSetOnDelete.removeAll()
                            editMode = .inactive
                        }
                    } label: {
                        Image(systemName: "filemenu.and.selection")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if editMode == .active {
                        Button(action: {
                            if !selectedTokens.isEmpty {
                                canEditGroup = true
                            }
                        }) {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        }
                    } else {
                        Button {
                            presentingSheet = .moreSettings
                            isSheetPresented = true
                        } label: {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 8)
                                .contentShape(Rectangle())
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if editMode == .active {
                        Button(action: {
                            if !selectedTokens.isEmpty {
                                isDeletionAlertPresented = true
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                    } else {
                        Menu {
                            #if !targetEnvironment(macCatalyst)
                            Button(action: {
                                presentingSheet = .addByScanning
                                isSheetPresented = true
                            }) {
                                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                            }
                            #endif
                            Button(action: {
                                presentingSheet = .addByQRCodeImage
                                isSheetPresented = true
                            }) {
                                Label("Import from Photos", systemImage: "photo")
                            }
                            Button(action: {
                                isFileImporterPresented = true
                            }) {
                                Label("Import from Files", systemImage: "doc.badge.plus")
                            }
                            Button(action: {
                                presentingSheet = .addByManually
                                isSheetPresented = true
                            }) {
                                Label("Enter Manually", systemImage: "text.cursor")
                            }
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(.leading, 8)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
            
        }
        .sheet(isPresented: $isSheetPresented) {
            switch presentingSheet {
            case .moreSettings:
                SettingsView(isPresented: $isSheetPresented, tokens: tokensToExport)
                    .environmentObject(settings)
            case .addByScanning:
                Scanner(isPresented: $isSheetPresented, codeTypes: [.qr], completion: handleScanning(result:))
                    .overlay(
                        TokenGroupOverlayButtonStyleView(buttonSelected: tokenGroupSelected)
                        ,alignment: .bottom)
            case .addByQRCodeImage:
                PhotoPicker(completion: handlePickedImage(uri:))
                    .overlay(
                        TokenGroupOverlayButtonStyleView(buttonSelected: tokenGroupSelected)
                        ,alignment: .bottom)
            case .addByManually:
                ManualEntryView(isPresented: $isSheetPresented, completion: addItem(_:))
                    .environmentObject(settings)
            case .cardDetailView:
                TokenDetailView(isPresented: $isSheetPresented, token: token(of: fetchedTokens[tokenIndex]))
            case .cardEditing:
                EditAccountView(isPresented: $isSheetPresented, token: token(of: fetchedTokens[tokenIndex]), tokenIndex: tokenIndex) { index, issuer, account, group in
                    handleAccountEditing(index: index, issuer: issuer, account: account, group: group)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.primary)
    }
    
    
    // MARK: - Modification
    private func addItem(_ token: Token) {
        withAnimation {
            let newTokenData = TokenData(context: viewContext)
            newTokenData.id = token.id
            newTokenData.uri = token.uri
            newTokenData.displayIssuer = token.displayIssuer
            newTokenData.displayAccountName = token.displayAccountName
            newTokenData.displayGroup = token.displayGroup
            let lastIndexNumber: Int64 = fetchedTokens.last?.indexNumber ?? Int64(fetchedTokens.count)
            newTokenData.indexNumber = lastIndexNumber + 1
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            generateCodes()
        }
    }
    private func move(from source: IndexSet, to destination: Int) {
        var idArray: [String] = fetchedTokens.map({ $0.id ?? Token().id })
        idArray.move(fromOffsets: source, toOffset: destination)
        for number in 0..<fetchedTokens.count {
            let item = fetchedTokens[number]
            if let index = idArray.firstIndex(where: { $0 == item.id }) {
                if Int64(index) != item.indexNumber {
                    fetchedTokens[number].indexNumber = Int64(index)
                }
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    private func deleteItems(offsets: IndexSet) {
        selectedTokens.removeAll()
        indexSetOnDelete = offsets
        isDeletionAlertPresented = true
    }
    private func cancelDeletion() {
        indexSetOnDelete.removeAll()
        selectedTokens.removeAll()
        isDeletionAlertPresented = false
    }
    private func performDeletion() {
        if !selectedTokens.isEmpty {
            _ = selectedTokens.map { oneSelection in
                _ = fetchedTokens.filter({ $0.id == oneSelection.id }).map(viewContext.delete)
            }
        } else if !indexSetOnDelete.isEmpty {
            _ = indexSetOnDelete.map({ fetchedTokens[$0] }).map(viewContext.delete)
        } else {
            viewContext.delete(fetchedTokens[tokenIndex])
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        indexSetOnDelete.removeAll()
        selectedTokens.removeAll()
        isDeletionAlertPresented = false
        generateCodes()
    }
    private var deletionAlert: Alert {
        let message: String = "Removing account will NOT turn off Two-Factor Authentication.\n\nMake sure you have alternate ways to sign into your service."
        return Alert(title: Text("Delete Account?"),
                     message: Text(NSLocalizedString(message, comment: "")),
                     primaryButton: .cancel(cancelDeletion),
                     secondaryButton: .destructive(Text("Delete"), action: performDeletion))
    }
    func SetSelectedTokengroups(selectedTokenGroup: String) -> Void {
        for token in selectedTokens {
            token.displayGroup = selectedTokenGroup
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        canEditGroup = false
        selectedTokens.removeAll()
    }
    
    // MARK: - Account Adding
    private func handleScanning(result: Result<String, ScannerView.ScanError>) {
        isSheetPresented = false
        switch result {
        case .success(let code):
            let uri: String = code.trimming()
            guard !uri.isEmpty else { return }
            let group: String = tokenGroupSelected.wrappedValue
            guard let newToken: Token = Token(uri: uri, group: group) else { return }
            addItem(newToken)
        case .failure(let error):
            logger.debug("\(error.localizedDescription)")
        }
    }
    private func handlePickedImage(uri: String) {
        let qrCodeUri: String = uri.trimming()
        guard !qrCodeUri.isEmpty else { return }
        let group: String = tokenGroupSelected.wrappedValue
        guard let newToken: Token = Token(uri: qrCodeUri, group: group) else { return }
        addItem(newToken)
    }
    private func handlePickedFile(url: URL) {
        guard let content: String = url.readText() else { return }
        let group: String = tokenGroupSelected.wrappedValue
        let lines: [String] = content.components(separatedBy: .newlines)
        _ = lines.map {
            if let newToken: Token = Token(uri: $0.trimming(), group: group) {
                addItem(newToken)
            }
        }
    }
    
    
    // MARK: - Methods
    private func token(of tokenData: TokenData) -> Token {
        guard let id: String = tokenData.id,
              let uri: String = tokenData.uri,
              let displayIssuer: String = tokenData.displayIssuer,
              let displayAccountName: String = tokenData.displayAccountName,
              let displayGroup: String = tokenData.displayGroup
        else { return Token() }
        guard let token = Token(id: id, uri: uri, displayIssuer: displayIssuer, displayAccountName: displayAccountName, displayGroup: displayGroup) else { return Token() }
        return token
    }
    private func generateCodes() {
        let placeholder: [String] = Array(repeating: "000000", count: 30)
        guard !fetchedTokens.isEmpty else {
            codes = placeholder
            return
        }
        let generated: [String] = fetchedTokens.map { code(of: $0) }
        codes = generated + placeholder
    }
    private func code(of tokenData: TokenData) -> String {
        guard let uri: String = tokenData.uri else { return "000000" }
        guard let group: String = tokenData.displayGroup else { return TokenGroupType.None.rawValue}
        guard let token: Token = Token(uri: uri, group: group) else { return "000000" }
        guard let code: String = OTPGenerator.totp(secret: token.secret, algorithm: token.algorithm, period: token.period) else { return "000000" }
        return code
    }
    
    private func handleAccountEditing(index: Int, issuer: String, account: String, group: String) {
        let item: TokenData = fetchedTokens[index]
        if item.displayIssuer != issuer {
            fetchedTokens[index].displayIssuer = issuer
        }
        if item.displayAccountName != account {
            fetchedTokens[index].displayAccountName = account
        }
        if item.displayGroup != group {
            fetchedTokens[index].displayGroup = group
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        isSheetPresented = false
    }
    
    private var tokensToExport: [Token] {
        return fetchedTokens.map({ token(of: $0) })
    }
    
    private func clearTemporaryDirectory() {
        let temporaryDirectoryUrl: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        guard let urls: [URL] = try? FileManager.default.contentsOfDirectory(at: temporaryDirectoryUrl, includingPropertiesForKeys: nil) else { return }
        _ = urls.map { try? FileManager.default.removeItem(at: $0) }
    }
    
    func fetchedTokens(tokenView: TokenGroupType) -> FetchedResults<TokenData> {
        switch tokenView {
        case .Personal:
            return fetchedTokensPeronal
        case .Work:
            return fetchedTokensWork
        default:
            return fetchedTokensAll
        }
    }
}

 var presentingSheet: SheetSet = .moreSettings
 var tokenIndex: Int = 0

 enum SheetSet {
    case moreSettings
    case addByScanning
    case addByQRCodeImage
    case addByManually
    case cardDetailView
    case cardEditing
}
