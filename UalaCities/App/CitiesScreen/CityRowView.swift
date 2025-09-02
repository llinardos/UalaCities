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
            VStack(alignment: .leading) {
                Text(viewModel.headingText).font(.headline)
                HStack(spacing: 2) {
                    Image(systemName: "mappin").font(.caption)
                    Text(viewModel.subheadText).font(.caption)
                }
            }
            Spacer()
            FavoriteButton(isSelected: $viewModel.favoriteButtonIsSelected) {
                viewModel.onFavoriteButtonTap()
            }.accessibilityIdentifier("FavoriteButton")
        }
    }
}
