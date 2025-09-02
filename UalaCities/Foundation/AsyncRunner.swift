//
//  AsyncRunner.swift
//  UalaCities
//
//  Created by Leandro Linardos on 02/09/2025.
//

import Foundation

protocol AsyncRunner {
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void)
}

struct GlobalRunner: AsyncRunner {
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = bgWork()
            DispatchQueue.main.async {
                mainWork(result)
            }
        }
    }
}
    
struct ImmediateRunner: AsyncRunner { // para tests
    func run<T>(bgWork: @escaping () -> T, mainWork: @escaping (T) -> Void) {
        let result = bgWork()
        mainWork(result)
    }
}
