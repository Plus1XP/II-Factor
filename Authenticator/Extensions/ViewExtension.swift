//
//  NavigationExtension.swift
//  Authenticator
//
//  Created by Plus1XP on 25/06/2021.
//

import SwiftUI
import Combine

public extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    func navigationBarSearch(_ searchText: Binding<String>) -> some View {
        return overlay(SearchBar(text: searchText).frame(width: 0, height: 0))
    }
}

fileprivate struct SearchBar: UIViewControllerRepresentable {
    @Binding
    var text: String
    
    init(text: Binding<String>) {
        self._text = text
    }
    
    func makeUIViewController(context: Context) -> SearchBarWrapperController {
        return SearchBarWrapperController()
    }
    
    func updateUIViewController(_ controller: SearchBarWrapperController, context: Context) {
        controller.searchController = context.coordinator.searchController
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UISearchResultsUpdating {
        @Binding
        var text: String
        let searchController: UISearchController
        
        private var subscription: AnyCancellable?
        
        init(text: Binding<String>) {
            self._text = text
            self.searchController = UISearchController(searchResultsController: nil)
            
            super.init()
            
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = true
            searchController.obscuresBackgroundDuringPresentation = false
            
            self.searchController.searchBar.text = self.text
            self.subscription = self.text.publisher.sink { _ in
                self.searchController.searchBar.text = self.text
            }
        }
        
        deinit {
            self.subscription?.cancel()
        }
        
        func updateSearchResults(for searchController: UISearchController) {
            guard let text = searchController.searchBar.text else { return }
            self.text = text
        }
    }
    
    class SearchBarWrapperController: UIViewController {
        var searchController: UISearchController? {
            didSet {
                self.parent?.navigationItem.searchController = searchController
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            self.parent?.navigationItem.searchController = searchController
        }
        override func viewDidAppear(_ animated: Bool) {
            self.parent?.navigationItem.searchController = searchController
        }
    }
}
