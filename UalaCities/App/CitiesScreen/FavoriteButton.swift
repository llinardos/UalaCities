//
//  FavoriteButton.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSelected: Bool
    let onTap: () -> Void
    init(isSelected: Binding<Bool>, onTap: @escaping () -> Void) {
        self.onTap = onTap
        self._isSelected = isSelected
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: isSelected ? "star.fill" : "star")
                .foregroundColor(isSelected ? .yellow : .primary)
                .font(.body)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(.plain)
    }
}
