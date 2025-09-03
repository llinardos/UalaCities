//
//  CityDetailScreenView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct CityDetailScreenView: View {
    @ObservedObject var viewModel: CityDetailScreenViewModel
    
    init(viewModel: CityDetailScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.rows, id: \.id) { rowViewModel in
                TitleAndValueRowView(viewModel: rowViewModel)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.titleText)
    }
}

extension CityDetailScreenView {
    struct TitleAndValueRowView: View {
        let viewModel: CityDetailScreenViewModel.TitleAndValueRowViewModel
        init(viewModel: CityDetailScreenViewModel.TitleAndValueRowViewModel) {
            self.viewModel = viewModel
        }
        var body: some View {
            VStack(alignment: .leading) {
                Text(viewModel.titleText).font(.caption)
                Text(viewModel.valueText).font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
