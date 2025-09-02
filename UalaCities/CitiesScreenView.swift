//
//  ContentView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import SwiftUI

struct CitiesScreenView: View {
    @ObservedObject var viewModel: CitiesScreenViewModel
    
    init(viewModel: CitiesScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isShowingSpinner {
                    ProgressView(viewModel.spinnerText)
                } else if viewModel.isShowingError {
                    VStack {
                        Text(viewModel.errorHeading).font(.headline)
                        Text(viewModel.errorSubhead).font(.subheadline)
                    }
                    .onTapGesture { viewModel.onErrorTap() }
                } else if viewModel.isShowingList {
                    VStack {
                        HStack(spacing: 8) {
                            SearchBarView(viewModel: viewModel.searchBar)
                            Button {
                                viewModel.onTapFavoriteFilterButton()
                            } label: {
                                Image(systemName: viewModel.favoriteFilterButtonIsSelected ? "star.fill" : "star")
                                    .foregroundColor(viewModel.favoriteFilterButtonIsSelected ? .yellow : .primary)
                                    .font(.body)
                            }
                            .accessibilityIdentifier("FavoriteFilterButton")
                            .accessibilityAddTraits(viewModel.favoriteFilterButtonIsSelected ? .isSelected : [])
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        PaginatedListView(viewModel.list) { row in
                            HStack {
                                Text(row.headingText)
                                Spacer()
                                Button {
                                    row.onFavoriteButtonTap()
                                } label: {
                                    Image(systemName: row.favoriteButtonIsSelected ? "star.fill" : "star")
                                        .foregroundColor(row.favoriteButtonIsSelected ? .yellow : .primary)
                                        .font(.body)
                                }
                                .accessibilityAddTraits(row.favoriteButtonIsSelected ? .isSelected : [])
                                .accessibilityIdentifier("FavoriteButton")
                                .buttonStyle(.plain)
                            }
                        }
                        .safeAreaInset(edge: .bottom) {
                            if viewModel.isShowingEmptyView {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title)
                                    VStack {
                                        Text(viewModel.emptyHeadingText).font(.headline)
                                        Text(viewModel.emptySubheadText).font(.subheadline)
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .onAppear { viewModel.onAppear() }
        }
    }
}

import Combine

class SearchBarViewModel: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var text: String = ""
    @Published var placeholderText: String = "Filter"
    @Published var cancelButtonText: String = "Cancel"
    @Published var isFocused: Bool = false
    @Published var showCancelButton: Bool = false
    @Published var showClearButton: Bool = false
    
    init(placeholderText: String, cancelButtonText: String = "Cancel") {
        self.placeholderText = placeholderText
        self.cancelButtonText = cancelButtonText
        
        $isFocused.sink { [weak self] isEditing in
            self?.showCancelButton = isEditing
        }.store(in: &subscriptions)
        
        $text.sink { [weak self] text in
            self?.showClearButton = !text.isEmpty
        }.store(in: &subscriptions)
    }
    
    func onTextFieldTap() {
        self.isFocused = true
    }
    
    func onClearTap() {
        self.text = ""
    }
}

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
                .tint(.primary)
            }
        }
    }
}

#Preview("ok") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 200, data: try! JSONEncoder().encode([City(_id: 1, name: "City 1", country: "AA")]))]), runner: GlobalRunner()))
}

#Preview("error") {
    CitiesScreenView(viewModel: .init(httpClient: StubbedHTTPClient([.init(statusCode: 500)]), runner: GlobalRunner()))
}
