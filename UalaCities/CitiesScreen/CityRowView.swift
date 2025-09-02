//
//  File.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation
import SwiftUI

struct CityRowView: View {
    @ObservedObject var viewModel: CityRowViewModel
    
    init(viewModel: CityRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.headingText)
            Spacer()
            Button {
                viewModel.onFavoriteButtonTap()
            } label: {
                Image(systemName: viewModel.favoriteButtonIsSelected ? "star.fill" : "star")
                    .foregroundColor(viewModel.favoriteButtonIsSelected ? .yellow : .primary)
                    .font(.body)
            }
            .accessibilityAddTraits(viewModel.favoriteButtonIsSelected ? .isSelected : [])
            .accessibilityIdentifier("FavoriteButton")
            .buttonStyle(.plain)
        }
    }
}
