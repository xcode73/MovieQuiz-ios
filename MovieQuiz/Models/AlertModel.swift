//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import Foundation

/// модель для алерта
struct AlertModel {
    let title: String
    let message: String
    let buttons: [String]
    let identifier: String
    let completion: () -> Void
}
