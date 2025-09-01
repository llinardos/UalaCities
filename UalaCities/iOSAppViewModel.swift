//
//  iOSApp.swift
//  UalaCities
//
//  Created by Leandro Linardos on 01/09/2025.
//

import Foundation
import Combine

protocol iOSAppScreen {}
extension CitiesScreenViewModel: iOSAppScreen {}

class Lala {}
extension Lala: iOSAppScreen {}

public class iOSAppViewModel: ObservableObject {
    @Published var mainScreen: iOSAppScreen
    
    public init() {
        mainScreen = CitiesScreenViewModel()
    }
}
