//
//  Array+Extensions.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 16.04.2024.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
