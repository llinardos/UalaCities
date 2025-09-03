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
            
            Button(action: { viewModel.tapOnInfoButton() }, label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            })
            .buttonStyle(.plain)
            .accessibilityIdentifier("InfoButton")
            
            FavoriteButton(viewModel: viewModel.favoriteButton)
                .accessibilityIdentifier("FavoriteButton")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.tapOnRow()
        }
        .listRowBackground(viewModel.isSelected ? Color.blue.opacity(0.2) : Color.clear)
    }
}
