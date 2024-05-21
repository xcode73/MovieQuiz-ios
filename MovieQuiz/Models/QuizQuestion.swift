//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 16.04.2024.
//

import Foundation

/// модель вопроса
struct QuizQuestion {
    let image: Data
    /// строка с вопросом о рейтинге фильма
    let text: String
    let correctAnswer: Bool
}
