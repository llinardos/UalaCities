//
//  SearchBarViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation
import Combine

class SearchBarViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var text: String = ""
    @Published var placeholderText: String = "Filter"
    @Published var cancelButtonText: String = "Cancel"
    @Published var isFocused: Bool = false
    @Published var showCancelButton: Bool = false
    @Published var showClearButton: Bool = false
    
    init(placeholderText: String, cancelButtonText: String = "Cancel") {
        self.placeholderText = placeholderText
        self.cancelButtonText = cancelButtonText
        
        $isFocused.sink { [weak self] isEditing in
            self?.showCancelButton = isEditing
        }.store(in: &subscriptions)
        
        $text.sink { [weak self] text in
            self?.showClearButton = !text.isEmpty
        }.store(in: &subscriptions)
    }
    
    func onTextFieldTap() {
        self.isFocused = true
    }
    
    func onClearTap() {
        self.text = ""
    }
}
