//
//  InfoMessageViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class InfoMessageViewModel: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var iconSystemName: String?
    @Published var headingText: String
    @Published var subheadText: String
    
    private var onTap: (() -> Void)?
    
    init(iconSystemName: String? = nil, headingText: String, subheadText: String, onTap: (() -> Void)? = nil) {
        self.iconSystemName = iconSystemName
        self.headingText = headingText
        self.subheadText = subheadText
        self.onTap = onTap
    }
    
    func tap() {
        onTap?()
    }
}
