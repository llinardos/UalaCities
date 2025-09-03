//
//  FavoriteButton.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI

struct FavoriteButton: View {
    @ObservedObject var viewModel: FavoriteButtonViewModel
    
    var body: some View {
        Button {
            viewModel.tap()
        } label: {
            Image(systemName: viewModel.isSelected ? "star.fill" : "star")
                .foregroundColor(viewModel.isSelected ? .yellow : .primary)
                .font(.body)
        }
        .accessibilityAddTraits(viewModel.isSelected ? .isSelected : [])
        .buttonStyle(.plain)
    }
}
