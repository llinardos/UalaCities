//
//  FavoriteButtonViewModel.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import Foundation

class FavoriteButtonViewModel: ObservableObject {
    @Published var isSelected = false
    
    private var onTap: ((Bool) -> Void)?
    
    init(onTap: @escaping (Bool) -> Void) {
        self.onTap = onTap
    }
    
    func tap() {
        isSelected.toggle()
        onTap?(isSelected)
    }
}
