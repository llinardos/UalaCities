//
//  SearchBarView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    @ObservedObject var viewModel: SearchBarViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .tint(.secondary)
                TextField("", text: $viewModel.text, prompt: Text(viewModel.placeholderText))
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onTapGesture {
                        viewModel.onTextFieldTap()
                    }
                    .onChange(of: isFocused) { _, isFocused in
                        self.viewModel.isFocused = isFocused
                    }
                    .accessibilityAddTraits(.isSearchField)
                if viewModel.showClearButton {
                    Button(action: {
                        self.viewModel.onClearTap()
                    }, label: { Image(systemName: "xmark.circle.fill")})
                        .tint(.secondary)
                }
            }
            .padding(8)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            if viewModel.showCancelButton {
                Button(viewModel.cancelButtonText) {
                    self.isFocused = false
                }
                .font(.body)
                .tint(.primary)
            }
        }
    }
}
