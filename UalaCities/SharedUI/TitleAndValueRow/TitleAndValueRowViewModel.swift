//
//  TitleAndValueRowViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class TitleAndValueRowViewModel: ObservableObject, Identifiable {
    @Published var titleText: String
    @Published var valueText: String
    @Published var isShowingArrow: Bool
    
    private var action: (() -> Void)?
    
    init(title: String, value: String, action: (() -> Void)? = nil) {
        self.titleText = title
        self.valueText = value
        self.action = action
        self.isShowingArrow = action != nil
    }
    
    func tap() {
        action?()
    }
}
