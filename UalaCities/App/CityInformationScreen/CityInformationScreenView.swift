//
//  CityInformationScreenView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct CityInformationScreenView: View {
    @ObservedObject var viewModel: CityInformationScreenViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.rows, id: \.id) { rowViewModel in
                TitleAndValueRowView(viewModel: rowViewModel)
                    .contentShape(Rectangle())
                    .onTapGesture { rowViewModel.tap() }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.titleText)
    }
}
