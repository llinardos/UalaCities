//
//  CityInformationScreenView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct CityInformationScreenView: View {
    @ObservedObject var viewModel: CityInformationScreenViewModel
    
    init(viewModel: CityInformationScreenViewModel) {
        self.viewModel = viewModel
    }
    
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

extension CityInformationScreenView {
    struct TitleAndValueRowView: View {
        let viewModel: CityInformationScreenViewModel.TitleAndValueRowViewModel
        init(viewModel: CityInformationScreenViewModel.TitleAndValueRowViewModel) {
            self.viewModel = viewModel
        }
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.titleText).font(.caption)
                    Text(viewModel.valueText).font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                if viewModel.isShowingArrow {
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}
