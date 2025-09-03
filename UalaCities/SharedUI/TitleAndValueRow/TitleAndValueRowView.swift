//
//  TitleAndValueRowView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct TitleAndValueRowView: View {
    @ObservedObject var viewModel: TitleAndValueRowViewModel
    
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
