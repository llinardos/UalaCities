//
//  InfoMessageView.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import SwiftUI

struct InfoMessageView: View {
    @ObservedObject var viewModel: InfoMessageViewModel
    
    var body: some View {
        if viewModel.isShowing {
            VStack(spacing: 16) {
                if let imageName = viewModel.iconSystemName {
                    Image(systemName: imageName)
                        .font(.title)
                }
                VStack {
                    Text(viewModel.headingText).font(.headline)
                    Text(viewModel.subheadText).font(.subheadline)
                }
            }
            .onTapGesture { viewModel.tap() }
        }
    }
}
