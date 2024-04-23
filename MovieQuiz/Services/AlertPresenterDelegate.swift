//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 22.04.2024.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    /// Показать алерт
    /// - Parameter model: модель для алерта
    func showResultAlert(model: AlertModel?)
}
