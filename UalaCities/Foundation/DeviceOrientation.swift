//
//  DeviceOrientation.swift
//  UalaCities
//
//  Created by Leandro Linardos on 03/09/2025.
//

import UIKit
import Combine

class DeviceOrientation {
    enum Value { case landscape, portrait }
    @Published var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

class UIKitDeviceOrientation: DeviceOrientation {
    private var cancellable: AnyCancellable?
    init() {
        super.init(.from(UIDevice.current))
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                self.value = .from(UIDevice.current)
            }
    }
}

extension DeviceOrientation.Value {
    static func from(_ device: UIDevice) -> DeviceOrientation.Value {
        UIDevice.current.orientation.isLandscape ? .landscape : .portrait
    }
}
