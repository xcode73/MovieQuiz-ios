//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 22.04.2024.
//

import Foundation

protocol AlertPresenterProtocol {
    
    /// Алерт с результатом квиза
    /// - Parameter model: модель результата квиза
    func resultAlert(model: QuizResultsViewModel)
}
